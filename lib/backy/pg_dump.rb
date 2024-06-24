require "fileutils"
require "etc"
require "open3"

module Backy
  class PgDump
    include Db
    include AppConfig

    DUMP_DIR = "db/dump"
    DUMP_CMD_OPTS = "--no-acl --no-owner --no-subscriptions --no-publications"

    def call
      setup_backup_directory
      log_start

      begin
        handle_replication { backup }
      rescue => e
        Logger.error("An error occurred during backup: #{e.message}")
      ensure
        if replica? && pause_replication?
          log_replication_resume
        end
      end
    end

    private

    def setup_backup_directory
      FileUtils.mkdir_p(DUMP_DIR)
    end

    def log_start
      Logger.log("Starting backy for #{database}")
    end

    def handle_replication
      if replica? && pause_replication?
        if pause_replication
          Logger.log("Replication paused.")
          yield
        else
          Logger.error("Failed to pause replication. Aborting backup.")
        end
      else
        yield
      end
    end

    def backup
      if use_parallel?
        Logger.log("Using multicore dump with pigz")
        parallel_backup
      else
        Logger.log("Using single core dump")
        plain_text_backup
      end
    end

    def log_replication_resume
      if resume_replication
        Logger.log("Replication resumed.")
      else
        Logger.error("Failed to resume replication. Manual intervention required.")
      end
    end

    def plain_text_backup
      timestamp = current_timestamp
      dump_file = "#{DUMP_DIR}/#{database}_#{whoami}@#{hostname}_#{timestamp}.sql.gz"

      cmd = "(#{pg_password_env}pg_dump #{pg_credentials} #{database} #{DUMP_CMD_OPTS} | gzip -9 > #{dump_file}) 2>&1 >> #{log_file}"

      Logger.log("Saving to #{dump_file} ... ")

      execute_command(cmd, "error. See #{log_file}")
    end

    def parallel_backup
      timestamp = current_timestamp
      dump_dir = "#{DUMP_DIR}/#{database}_dump_parallel_#{timestamp}"
      dump_file = "#{dump_dir}.tar.gz"

      pg_dump_cmd = "#{pg_password_env}pg_dump -Z0 -j #{Etc.nprocessors} -Fd #{database} -f #{dump_dir} #{pg_credentials} #{DUMP_CMD_OPTS}"
      tar_cmd = "tar -cf - #{dump_dir} | pigz -p #{Etc.nprocessors} > #{dump_file}"
      cleanup_cmd = "rm -rf #{dump_dir}"

      execute_command("#{pg_password_env}#{pg_dump_cmd} 2>&1 >> #{log_file}", "pg_dump failed. See #{log_file} for details.")
      execute_command(tar_cmd, "Compression failed. See #{log_file} for details.")
      execute_command(cleanup_cmd, "Cleanup failed. See #{log_file} for details.")

      Logger.success("Backup process completed. Output file: #{dump_file}")
    end

    def execute_command(cmd, error_message)
      if system(cmd)
        Logger.success("done")
      else
        Logger.error(error_message)
      end
    end

    def current_timestamp
      Time.now.strftime("%Y%m%d_%H%M%S")
    end

    def hostname
      @hostname ||= `hostname`.strip
    end

    def whoami
      @whoami ||= `whoami`.strip
    end

    def pause_replication
      query = "SELECT pg_wal_replay_pause();"
      success, _output = execute_sql(query)
      success
    end

    def resume_replication
      query = "SELECT pg_wal_replay_resume();"
      success, _output = execute_sql(query)
      success
    end

    def execute_sql(query)
      command = %(#{pg_password_env}psql #{pg_credentials} -d #{database} -c "#{query}")
      output = ""
      Open3.popen3(command) do |_stdin, stdout, stderr, wait_thr|
        while (line = stdout.gets)
          output << line
        end
        while (line = stderr.gets)
          puts "Error: #{line}"
        end
        exit_status = wait_thr.value
        [exit_status.success?, output]
      end
    end

    def replica?
      @is_replica ||= begin
        query = "SELECT pg_is_in_recovery();"
        success, output = execute_sql(query)
        if success && output.include?("t")
          Logger.log("Database is a replica.")
          true
        else
          false
        end
      end
    end
  end
end

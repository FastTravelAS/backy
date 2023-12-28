require "fileutils"
require "etc"

module Backy
  class PgDump
    include Db
    include AppConfig

    DUMP_DIR = "db/dump"
    DUMP_CMD_OPTS = "--no-acl --no-owner --no-subscriptions --no-publications"

    def call
      FileUtils.mkdir_p(DUMP_DIR)
      Logger.log("Starting backy for #{database}")

      if use_parallel?
        Logger.log("Using multicore dump with pigz")
        parallel_backup
      else
        Logger.log("Using single core dump")
        plain_text_backup
      end
    end

    private

    def plain_text_backup
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      dump_file = "#{DUMP_DIR}/#{database}_#{whoami}@#{hostname}_single_#{timestamp}.sql.gz"

      cmd = "(#{pg_password_env}pg_dump #{pg_credentials} #{database} #{DUMP_CMD_OPTS} | gzip -9 > #{dump_file}) 2>&1 >> #{log_file}"

      print "Saving to #{dump_file} ... "

      if system(cmd)
        Logger.success("done")
      else
        Logger.error("error. See #{log_file}")
        return
      end

      dump_file
    end

    def parallel_backup
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      dump_dir = "#{DUMP_DIR}/#{database}_dump_parallel_#{timestamp}"
      dump_file = "#{dump_dir}.tar.gz"

      pg_dump_cmd = "pg_dump -Z0 -j #{Etc.nprocessors} -Fd #{database} -f #{dump_dir} #{pg_credentials} #{DUMP_CMD_OPTS}"
      tar_cmd = "tar -cf - #{dump_dir} | pigz -p #{Etc.nprocessors} > #{dump_file}"
      cleanup_cmd = "rm -rf #{dump_dir}"

      Logger.log("Running pg_dump #{database}")
      if system("#{pg_password_env}#{pg_dump_cmd} 2>&1 >> #{log_file}")
        Logger.log("pg_dump completed successfully.")
      else
        Logger.error("pg_dump failed. See #{log_file} for details.")
        return
      end

      # Execute tar command
      Logger.log("Compressing #{dump_dir}")
      if system(tar_cmd)
        Logger.log("Compression completed successfully.")
      else
        Logger.error("Compression failed. See #{log_file} for details.")
        return
      end

      # Execute cleanup command
      Logger.log("Cleaning up #{dump_dir}")
      if system(cleanup_cmd)
        Logger.log("Cleanup completed successfully.")
      else
        Logger.error("Cleanup failed. See #{log_file} for details.")
        return
      end

      Logger.success("Backup process completed. Output file: #{dump_file}")

      dump_file # Return the name of the dump file
    end

    def hostname
      @hostname ||= `hostname`.strip
    end

    def whoami
      @whoami ||= `whoami`.strip
    end
  end
end

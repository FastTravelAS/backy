require "fileutils"
require "etc"

module Backy
  class PgDump
    include Db
    include AppConfig
    include Helper

    DUMP_DIR = "db/dump"
    DUMP_CMD_OPTS = "--no-acl --no-owner --no-subscriptions --no-publications"

    def call
      FileUtils.mkdir_p(DUMP_DIR)
      log_message("Starting backy for #{database}")
      # Detect if pigz binary is available
      # If it is, use it to speed up the dump
      # pigz is a parallel gzip implementation
      # https://zlib.net/pigz/
      pigz_installed = system("which pigz > /dev/null 2>&1")

      # Determine if the system is multicore
      multicore = Etc.nprocessors > 1

      use_multicore = ENV["BACKY_USE_MULTICORE"] == "true"

      # If pigz is installed and the system is multicore, use parallel dump
      if pigz_installed && multicore && use_multicore
        log_message("Using multicore dump with pigz")
        parallel_backup
      else
        log_message("Pigz not installed or system is not multicore")
        log_message("Using single core dump")
        plain_text_backup
      end
    end

    private

    def plain_text_backup
      dump_file = "#{DUMP_DIR}/#{database}_#{whoami}@#{hostname}_#{Time.zone.now.strftime("%Y%m%d_%H%M%S")}.sql.gz"

      cmd = "(#{pg_password_env}pg_dump #{pg_credentials} #{database} #{DUMP_CMD_OPTS} | gzip -9 > #{dump_file}) 2>&1 >> #{log_file}"

      print "Saving to #{dump_file} ... "

      if system(cmd)
        puts "done"
      else
        puts "error. See #{log_file}"

        return
      end

      dump_file
    end

    def parallel_backup
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      dump_dir = "#{DUMP_DIR}/#{database}_dump_#{timestamp}"
      dump_file = "#{dump_dir}.tar.gz"

      pg_dump_cmd = "pg_dump -Z0 -j #{Etc.nprocessors} -Fd #{database} -f #{dump_dir} #{pg_credentials} #{DUMP_CMD_OPTS}"
      tar_cmd = "tar -cf - #{dump_dir} | pigz -p #{Etc.nprocessors} > #{dump_file}"
      cleanup_cmd = "rm -rf #{dump_dir}"

      log_message("Running pg_dump #{database}")
      if system("#{pg_password_env}#{pg_dump_cmd} 2>&1 >> #{log_file}")
        log_message("pg_dump completed successfully.")
      else
        log_message("pg_dump failed. See #{log_file} for details.")
        return
      end

      # Execute tar command
      log_message("Compressing #{dump_dir}")
      if system(tar_cmd)
        log_message("Compression completed successfully.")
      else
        log_message("Compression failed. See #{log_file} for details.")
        return
      end

      # Execute cleanup command
      log_message("Cleaning up #{dump_dir}")
      if system(cleanup_cmd)
        log_message("Cleanup completed successfully.")
      else
        log_message("Cleanup failed. See #{log_file} for details.")
        return
      end

      log_message("Backup process completed. Output file: #{dump_file}")

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

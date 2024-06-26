module Backy
  class PgRestore
    include Db
    include AppConfig

    DUMP_DIR = "db/dump"

    def initialize(file_name:)
      @file_name = file_name
    end

    def call
      pigz_installed = system("which pigz > /dev/null 2>&1")
      multicore = Etc.nprocessors > 1
      use_multicore = ENV["BACKY_USE_PARALLEL"] == "true"

      if pigz_installed && multicore && use_multicore
        Logger.log("Using parallel restore with pigz")
        parallel_restore
      else
        Logger.log("Pigz not installed or system is not multicore")
        Logger.log("Using plain text restore")
        plain_text_restore
      end
    end

    private

    attr_reader :file_name

    def plain_text_restore
      cmd = "(#{pg_password_env}psql -c \"#{terminate_connection_sql};\" #{pg_credentials} #{database}; #{pg_password_env}dropdb #{pg_credentials} #{database}; #{pg_password_env}createdb #{pg_credentials} #{database}; gunzip -c #{file_name} | #{pg_password_env}psql #{pg_credentials} -q -d #{database}) 2>&1 >> #{log_file}"

      Logger.log("Restoring #{database} from #{file_name} ...")
      if system(cmd)
        Logger.log("Database restoration completed successfully.")
      else
        Logger.log("Database restoration failed. See #{log_file} for details.")
      end
    end

    def parallel_restore
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      dump_dir = "#{DUMP_DIR}/#{database}_dump_#{timestamp}"
      FileUtils.mkdir_p(dump_dir)

      decompress_cmd = "pigz -p #{Etc.nprocessors} -dc #{file_name} | tar -C #{dump_dir} --strip-components 3 -xf -"
      restore_cmd = "pg_restore -j #{Etc.nprocessors} -Fd -O -d #{database} #{dump_dir}"

      # Terminate connections and drop/create database
      terminate_and_recreate_db = "(#{pg_password_env}psql -c \"#{terminate_connection_sql};\" #{pg_credentials} #{database}; #{pg_password_env}dropdb #{pg_credentials} #{database}; #{pg_password_env}createdb #{pg_credentials} #{database}) 2>&1 >> #{log_file}"

      Logger.log("Terminating connections to #{database}")
      if system(terminate_and_recreate_db)
        Logger.log("Database connections terminated and database recreated.")
      else
        Logger.log("Error during database termination and recreation. See #{log_file}")
        return
      end

      # Decompress and restore
      Logger.log("Decompressing #{file_name} into #{dump_dir} ...")
      if system(decompress_cmd)
        Logger.log("Decompression completed successfully.")

        # Check the expected file
        unless File.exist?("#{dump_dir}/toc.dat")
          Logger.log("toc.dat not found in #{dump_dir}.")
          return
        end
      else
        Logger.log("Decompression failed. See #{log_file} for details.")
        return
      end

      Logger.log("Restoring database from #{dump_dir} ...")
      if system(restore_cmd)
        Logger.log("Database restoration completed successfully.")
      else
        Logger.log("Database restoration failed. See #{log_file} for details.")
        return
      end

      Logger.log("Cleanup: Removing #{dump_dir} ...")
      FileUtils.rm_rf(dump_dir)
      Logger.log("Cleanup completed.")
    end

    def terminate_connection_sql
      "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{database}' AND pid <> pg_backend_pid();"
    end
  end
end

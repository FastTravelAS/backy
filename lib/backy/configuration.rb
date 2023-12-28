module Backy
  class Configuration
    attr_writer(
      :pg_host,
      :pg_port,
      :pg_database,
      :pg_username,
      :pg_password,
      :s3_region,
      :s3_access_key,
      :s3_secret,
      :s3_bucket,
      :app_name,
      :environment,
      :use_parallel,
      :log_file
    )

    def load
      local_config_file = File.join(Dir.pwd, '.backyrc')
      global_config_file = File.join(Dir.home, '.backyrc')

      config_file = File.exist?(local_config_file) ? local_config_file : global_config_file
      Logger.log("Loading configuration from #{config_file}...") if File.exist?(config_file)
      load_from_file(config_file) if File.exist?(config_file)
    end

    def pg_host
      @pg_host ||= ENV["PG_HOST"]
    end

    def pg_port
      @pg_port ||= ENV["PG_PORT"]
    end

    def pg_database
      @pg_database ||= ENV["PG_DATABASE"]
    end

    def pg_username
      @pg_username ||= ENV["PG_USERNAME"]
    end

    def pg_password
      @pg_password ||= ENV["PG_PASSWORD"]
    end

    def s3_region
      @s3_region ||= ENV["S3_REGION"]
    end

    def s3_access_key
      @s3_access_key ||= ENV["S3_ACCESS_KEY"]
    end

    def s3_secret
      @s3_secret ||= ENV["S3_SECRET"]
    end

    def s3_bucket
      @s3_bucket ||= ENV["S3_BUCKET"]
    end

    def use_parallel
      @use_parallel ||= ENV["BACKY_USE_PARALLEL"] == "true"
    end

    def use_parallel?
      use_parallel && pigz_installed && multicore
    end

    # Detect if pigz binary is available
    # If it is, use it to speed up the dump
    # pigz is a parallel gzip implementation
    # https://zlib.net/pigz/
    def pigz_installed
      @pigz_installed ||= system("which pigz > /dev/null 2>&1")
    end

    # Determine if the system is multicore
    def multicore
      @multicore ||= Etc.nprocessors > 1
    end

    def app_name
      @app_name ||= ENV["APP_NAME"].presence || "backy"
    end

    def environment
      @environment ||= "development"
    end

    def log_file
      @log_file ||= default_log_file
    end

    private

    def default_log_file
      if Gem.win_platform?
        # Windows default path
        File.join(Dir.home, "AppData", "Local", "#{app_name}", "log", "#{app_name}.log")
      else
        # Unix-like systems default path
        File.join(Dir.home, ".local", "share", "#{app_name}", "log", "#{app_name}.log")
      end
    end

    def load_from_file(file_path)
      configuration = YAML.load_file(file_path)

      @s3_access_key = configuration.dig("defaults", "s3", "access_key_id")
      @s3_secret = configuration.dig("defaults", "s3", "secret_access_key")
      @s3_region = configuration.dig("defaults", "s3", "region")
      @s3_bucket = configuration.dig("defaults", "s3", "bucket")

      @pg_host = configuration.dig("defaults", "database", "host")
      @pg_port = configuration.dig("defaults", "database", "port")
      @pg_username = configuration.dig("defaults", "database", "username")
      @pg_password = configuration.dig("defaults", "database", "password")
      @pg_database = configuration.dig("defaults", "database", "database_name")

      @app_name = configuration.dig("defaults", "app_name") || "backy"
      @environment = configuration.dig("defaults", "environment") || "development"
      @log_file = configuration.dig("defaults", "log", "file") || default_log_file
      @use_parallel = configuration.dig("defaults", "use_parallel") || false
    end
  end
end

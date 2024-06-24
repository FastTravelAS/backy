require "fileutils"
require "etc"
require "open3"
require "yaml"
require "uri"

module Backy
  class Configuration
    DEFAULTS = {
      pg_host: nil,
      pg_port: nil,
      pg_database: nil,
      pg_username: nil,
      pg_password: nil,
      s3_region: nil,
      s3_access_key: nil,
      s3_secret: nil,
      s3_bucket: nil,
      s3_prefix: "./db/dump/",
      app_name: "backy",
      environment: "development",
      use_parallel: false,
      pause_replication: true,
      log_file: "./log/backy.log",
      local_backup_path: nil
    }.freeze

    CONFIG_FILE_NAME = ".backyrc"

    attr_accessor(*DEFAULTS.keys)

    def initialize
      DEFAULTS.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def load
      load_config_file

      load_from_env
    end

    def pg_url=(url)
      @pg_url = url
      pg_config = parse_postgres_uri(url)
      @pg_host = pg_config[:host]
      @pg_port = pg_config[:port]
      @pg_username = pg_config[:username]
      @pg_password = pg_config[:password]
      @pg_database = pg_config[:database_name]
    end

    def pg_url
      @pg_url ||= ENV["PG_URL"]
    end

    def use_parallel?
      use_parallel && pigz_installed && multicore
    end

    def pause_replication?
      pause_replication
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

    def log_file
      @log_file ||= default_log_file
    end

    private

    def default_log_file
      if Gem.win_platform?
        # Windows default path
        File.join(Dir.home, "AppData", "Local", app_name, "log", app_name, ".log")
      else
        # Unix-like systems default path
        File.join(Dir.home, ".local", "share", app_name, "log", app_name, ".log")
      end
    end

    def load_config_file
      local_config_file = File.join(Dir.pwd, CONFIG_FILE_NAME)
      global_config_file = File.join(Dir.home, CONFIG_FILE_NAME)

      config_file = File.exist?(local_config_file) ? local_config_file : global_config_file
      if File.exist?(config_file)
        Logger.log("Loading configuration from #{config_file}...")
        load_from_file(config_file)
      end
    end

    def load_from_file(file_path)
      configuration = YAML.load_file(file_path)

      shared_config = configuration.fetch("shared", {})
      environment_config = configuration.fetch(environment, {})

      merged_config = deep_merge(shared_config, environment_config)

      apply_config(merged_config)
    end

    def apply_config(config)
      config.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?("#{key}=")
      end

      self.pg_url = @pg_url if @pg_url
    end

    def load_from_env
      ENV.each do |key, value|
        case key
        when "PG_HOST" then @pg_host = value
        when "PG_PORT" then @pg_port = value
        when "PG_DATABASE" then @pg_database = value
        when "PG_USERNAME" then @pg_username = value
        when "PG_PASSWORD" then @pg_password = value
        when "S3_REGION" then @s3_region = value
        when "S3_ACCESS_KEY" then @s3_access_key = value
        when "S3_SECRET" then @s3_secret = value
        when "S3_BUCKET" then @s3_bucket = value
        when "S3_PREFIX" then @s3_prefix = value
        when "APP_NAME" then @app_name = value
        when "BACKY_USE_PARALLEL" then @use_parallel = value == "true"
        when "BACKY_PAUSE_REPLICATION" then @pause_replication = value == "true"
        when "LOCAL_BACKUP_PATH" then @local_backup_path = value
        end
      end
    end

    def parse_postgres_uri(uri)
      parsed_uri = URI.parse(uri)

      {
        adapter: "postgresql",
        host: parsed_uri.host,
        port: parsed_uri.port,
        username: parsed_uri.user,
        password: parsed_uri.password,
        database_name: parsed_uri.path[1..]
      }
    end

    def deep_merge(hash1, hash2)
      merged = hash1.dup
      hash2.each do |key, value|
        merged[key] = if value.is_a?(Hash) && hash1[key].is_a?(Hash)
          deep_merge(hash1[key], value)
        else
          value
        end
      end
      merged
    end
  end
end

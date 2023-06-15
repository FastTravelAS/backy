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
      :log_file
    )

    def pg_host
      @pg_host ||= ActiveRecord::Base.connection_db_config.configuration_hash[:host]
    end

    def pg_port
      @pg_port ||= ActiveRecord::Base.connection_db_config.configuration_hash[:port]
    end

    def pg_database
      @pg_database ||= ActiveRecord::Base.connection_db_config.configuration_hash[:database]
    end

    def pg_username
      @pg_username ||= ActiveRecord::Base.connection_db_config.configuration_hash[:username]
    end

    def pg_password
      @pg_password ||= ActiveRecord::Base.connection_db_config.configuration_hash[:password]
    end

    def s3_region
      @region ||= ENV["S3_REGION"]
    end

    def s3_access_key
      @s3_access_key ||= ENV["S3_ACCESS_KEY"]
    end

    def s3_secret
      @s3_secret ||= ENV["S3_SECRET"]
    end

    def s3_bucket
      @bucket ||= ENV["S3_BUCKET"]
    end

    def app_name
      if defined?(Rails)
        @app_name ||= Rails.application.class.name.split("::").first.underscore
      else
        @app_name
      end
    end

    def environment
      if defined?(Rails)
        @environment ||= Rails.env
      else
        @environment
      end
    end

    def log_file
      @log_file ||= "log/backy.log"
    end
  end
end

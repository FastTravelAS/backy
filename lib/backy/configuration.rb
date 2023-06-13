module Backy
  class Configuration
    LOG_FILE = "log/db_backup.log"

    attr_writer(
      :host,
      :port,
      :database,
      :username,
      :password,
      :pg_password,
      :app_name,
      :environment,
      :s3_region,
      :s3_access_key,
      :s3_secret,
      :s3_bucket
    )

    def self.configure
      yield(configuration)
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def host
      @host ||= ActiveRecord::Base.connection_db_config.configuration_hash[:host]
    end

    def port
      @port ||= ActiveRecord::Base.connection_db_config.configuration_hash[:port]
    end

    def database
      @database ||= ActiveRecord::Base.connection_db_config.configuration_hash[:database]
    end

    def username
      @username ||= ActiveRecord::Base.connection_db_config.configuration_hash[:username]
    end

    def password
      @password ||= ActiveRecord::Base.connection_db_config.configuration_hash[:password]
    end

    def pg_password
      @pg_password ||= password.present? ? "PGPASSWORD='#{password}' " : ""
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

    def s3_configured?
      %w[S3_REGION S3_ACCESS_KEY S3_SECRET S3_BUCKET].all? { |key| ENV.key?(key) }
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

    def s3_credentials
      @credentials ||= Aws::Credentials.new(ENV["S3_ACCESS_KEY"], ENV["S3_SECRET"])
    end

    def bucket
      @bucket ||= ENV["S3_BUCKET"]
    end

    def s3
      @s3 ||= Aws::S3::Client.new(region:, credentials:)
    end
  end
end

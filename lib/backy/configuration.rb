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
      :s3_folder,
      :app_name,
      :environment,
      :log_file
    )

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

    def s3_folder
      @s3_folder ||= "db/dump/"
    end

    def app_name
      @app_name ||= "backy"
    end

    def environment
      @environment ||= "development"
    end

    def log_file
      @log_file ||= "log/backy.log"
    end
  end
end

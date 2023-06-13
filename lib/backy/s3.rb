require "aws-sdk-s3"

module Backy
  module S3
    private

    def s3_configured?
      Backy.configuration.s3_configured?
    end

    def region
      Backy.configuration.s3_region
    end

    def credentials
      Backy.configuration.s3_credentials
    end

    def bucket
      Backy.configuration.s3_bucket
    end

    def s3
      @s3 ||= Aws::S3::Client.new(region: region, credentials: credentials)
    end
  end
end

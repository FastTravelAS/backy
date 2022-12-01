require "aws-sdk-s3"

module Rubynor
  module DB
    module Backup
      module S3Config
        private

        def s3_configured?
          %w[S3_REGION S3_ACCESS_KEY S3_SECRET S3_BUCKET].all? { |key| ENV.key?(key) }
        end

        def region = @region ||= ENV["S3_REGION"]

        def credentials = @credentials ||= Aws::Credentials.new(ENV["S3_ACCESS_KEY"], ENV["S3_SECRET"])

        def bucket = @bucket ||= ENV["S3_BUCKET"]

        def s3 = @s3 ||= Aws::S3::Client.new(region:, credentials:)
      end
    end
  end
end

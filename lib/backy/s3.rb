require "aws-sdk-s3"
require 'forwardable'

module Backy
  module S3
    extend Forwardable

    private

    def_delegator "Backy.configuration", :s3_region, :region
    def_delegator "Backy.configuration", :s3_secret, :secret
    def_delegator "Backy.configuration", :s3_bucket, :bucket
    def_delegator "Backy.configuration", :s3_access_key, :access_key
    def_delegator "Backy.configuration", :s3_folder, :folder

    def s3
      @s3 ||= Aws::S3::Client.new(region: region, credentials: s3_credentials)
    end

    def s3_configured?
      [region, access_key, secret, bucket].all?(&:present?)
    end

    def s3_credentials
      @credentials ||= Aws::Credentials.new(access_key, secret)
    end
  end
end

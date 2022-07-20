module DB
  module Backup
    class S3List < ApplicationService
      include S3Config

      DEFAULT_PREFIX = "db/dump/"

      def initialize(prefix: nil)
        @prefix = prefix || DEFAULT_PREFIX
      end

      def call
        return [] unless s3_configured?

        response = s3.list_objects(prefix:, bucket:)

        result = response.contents.map(&:key)

        while response.next_page?
          response = response.next_page

          result += response.contents.map(&:key)
        end

        result.sort
      end

      private

      attr_reader :prefix
    end
  end
end

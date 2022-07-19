module DB
  module Backup
    class S3Load < ApplicationService
      include S3Config

      def initialize(file_name:, key: nil)
        @file_name = file_name
        @key = key || file_name
      end

      def call
        return file_name if File.exist?(file_name)

        print "Loading #{key} from S3 ... "

        begin
          s3.get_object(response_target: file_name, key:, bucket:)
        rescue Aws::S3::Errors::NoSuchKey
          puts "error. No such key #{key}"

          exit
        end

        puts "done"

        file_name
      end

      private

      attr_reader :key, :file_name
    end
  end
end

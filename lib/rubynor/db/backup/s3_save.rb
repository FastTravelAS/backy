module Rubynor
  module DB
    module Backup
      class S3Save < Base
        include S3Config

        DEFAULT_EXPIRE_AFTER = 1.month

        def initialize(file_name:, key: nil, expire_after: nil)
          @file_name = file_name
          @key = key || file_name
          @expires = (expire_after || DEFAULT_EXPIRE_AFTER).from_now
        end

        def call
          print "Sending #{file_name} to S3 ... "

          unless File.exist?(file_name)
            puts "error. #{file_name} does not exist"

            return
          end

          File.open(file_name, "rb") do |body|
            s3.put_object(key:, body:, bucket:, expires:)
          end

          puts "done"
        end

        private

        attr_reader :file_name, :key, :expires
      end
    end
  end
end

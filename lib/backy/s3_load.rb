module Backy
  class S3Load
    include S3

    def initialize(file_name:, key: nil)
      @file_name = file_name
      @key = key || file_name
    end

    def call
      return file_name if File.exist?(file_name)

      print "Loading #{key} from S3 ... "

      FileUtils.mkdir_p("/tmp/#{File.dirname(file_name)}")
      Tempfile.create(file_name) do |tempfile|
        response_target = tempfile.path

        begin
          s3.get_object(response_target: response_target, key: key, bucket: bucket)
          FileUtils.mkdir_p(File.dirname(file_name))
          FileUtils.mv(response_target, file_name)
        rescue Aws::S3::Errors::NoSuchKey
          puts "error. No such key #{key}"
        ensure
          if File.exist?(tempfile.path)
            tempfile.close
            File.delete(tempfile.path)
          end
        end
      end

      puts "done"

      file_name
    end

    private

    attr_reader :key, :file_name
  end
end

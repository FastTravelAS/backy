module Backy
  class S3Save
    include S3

    DEFAULT_EXPIRE_AFTER = 1.month
    PART_SIZE = 50 * 1024 * 1024
    MAX_THREADS = 5

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

      file_size = File.size(file_name)

      if file_size < 5 * 1024 * 1024 * 1024
        upload_simple
      else
        upload_multipart
      end

      puts "done"
    end

    private

    attr_reader :file_name, :key, :expires

    def upload_simple
      puts "Uploading #{file_name} to S3 ... "
      File.open(file_name, "rb") do |body|
        s3.put_object(key: key, body: body, bucket: bucket, expires: expires)
      end
    end

    def upload_multipart
      puts "Uploading #{file_name} to S3 (multipart) ... "
      upload_id = s3.create_multipart_upload(bucket: bucket, key: key, expires: expires).upload_id
      parts = []
      mutex = Mutex.new

      file_size = File.size(file_name)
      total_parts = (file_size.to_f / PART_SIZE).ceil

      part_numbers = (1..total_parts).to_a

      part_numbers.each_slice(MAX_THREADS) do |batch|
        threads = batch.map do |part_number|
          Thread.new do
            start_pos = (part_number - 1) * PART_SIZE
            end_pos = [start_pos + PART_SIZE, file_size].min

            part_data = nil
            File.open(file_name, "rb") do |file|
              file.seek(start_pos)
              part_data = file.read(end_pos - start_pos)
            end

            resp = s3.upload_part(
              bucket: bucket,
              key: key,
              upload_id: upload_id,
              part_number: part_number,
              body: part_data
            )

            mutex.synchronize do
              parts << {etag: resp.etag, part_number: part_number}
            end
          end
        end

        threads.each(&:join)
      end

      sorted_parts = parts.sort_by { |p| p[:part_number] }

      s3.complete_multipart_upload(
        bucket: bucket,
        key: key,
        upload_id: upload_id,
        multipart_upload: {
          parts: sorted_parts
        }
      )
    rescue => e
      puts "\nError during multipart upload: #{e.message}"
      s3.abort_multipart_upload(bucket: bucket, key: key, upload_id: upload_id)
      raise e
    end
  end
end

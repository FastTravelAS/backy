module Backy
  class S3List
    include S3

    def call
      return [] unless s3_configured?

      response = s3.list_objects(prefix: folder, bucket: bucket)

      result = response.contents.map(&:key)

      while response.next_page?
        response = response.next_page

        result += response.contents.map(&:key)
      end

      result.sort
    end
  end
end

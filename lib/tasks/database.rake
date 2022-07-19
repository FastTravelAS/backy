require "aws-sdk-s3"

namespace :db do
  namespace :backup do
    task dump: :environment do
      pg_dump
    end

    task push: :environment do
      save_to_s3(pg_dump)
    end

    task upload: :environment do
      file_name = ENV["DUMP_FILE"]

      if file_name.nil? || !File.exist?(file_name)
        puts "Plese set DUMP_FILE env variable to the existing local file to save to S3"

        exit
      end

      save_to_s3(file_name)
    end

    task download: :environment do
      file_name = ENV["DUMP_FILE"]

      if file_name.nil? || File.exist?(file_name)
        puts "Plese set DUMP_FILE env variable to the missing remote file to download"

        exit
      end

      pg_restore(load_from_s3_if_missing(file_name))
    end

    task list: :environment do
      DB::Backup::List.call
    end

    task restore: :environment do
      file_name = ENV["DUMP_FILE"]

      if file_name.nil?
        puts "Plese set DUMP_FILE env variable to the local/s3 file to restore from"
        exit
      end

      pg_restore(load_from_s3_if_missing(file_name))
    end

    private

    def pg_dump
      DB::Backup::PgDump.call
    end

    def save_to_s3(file_name)
      DB::Backup::S3Save.call(file_name:)
    end

    def load_from_s3_if_missing(file_name)
      DB::Backup::S3Load.call(file_name:)
    end

    def pg_restore(file_name)
      DB::Backup::PgRestore.call(file_name:)
    end
  end
end

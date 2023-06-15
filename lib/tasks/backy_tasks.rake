require "aws-sdk-s3"

namespace :backy do
  task dump: :environment do
    pg_dump
  end

  task push: :environment do
    file_name = pg_dump
    save_to_s3(file_name)
    File.delete(file_name) if File.exist?(file_name)
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

    load_from_s3_if_missing(file_name)
  end

  task list: :environment do
    list = Backy::List.call

    list.each do |list_item|
      puts "#{list_item.local? ? "local" : "     "} #{list_item.remote? ? "remote" : "      "} : #{list_item.dump_file}"
    end

    if list.any?
      puts

      puts "To restore run backy:restore setting DUMP_FILE."
      puts "Example:"
      puts "  bundle exec rails backy:restore DUMP_FILE=#{list.last.dump_file}"
    end
  end

  task restore: :environment do
    template_file_name = ENV["DUMP_FILE"]
    file_name = Backy::List.call.reverse.find { |list_item| list_item.dump_file.starts_with?(template_file_name) }&.dump_file if template_file_name.present?

    if file_name.nil?
      puts "Plese set DUMP_FILE env variable to the local/s3 file (or prefix) to restore from."

      exit
    end

    pg_restore(load_from_s3_if_missing(file_name))
  end

  private

  def pg_dump
    Backy::PgDump.new.call
  end

  def save_to_s3(file_name)
    Backy::S3Save.new(file_name: file_name).call
  end

  def load_from_s3_if_missing(file_name)
    Backy::S3Load.new(file_name: file_name).call
  end

  def pg_restore(file_name)
    Backy::PgRestore.new(file_name: file_name).call
  end
end

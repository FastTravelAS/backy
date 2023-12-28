require "thor"
require "yaml"

module Backy
  class CLI < Thor
    def initialize(*args)
      Logger.log("Initializing Backy CLI...")
      super
      Backy.setup
    end

    desc "dump", "Dump the database"
    def dump
      Backy::PgDump.new.call
      Logger.success("Database dumped successfully.")
    end

    desc "push", "Push dump to S3 and delete local file"
    def push
      file_name = Backy::PgDump.new.call
      save_to_s3(file_name)
      File.delete(file_name) if File.exist?(file_name)
      Logger.success("Dump pushed to S3 and local file deleted.")
    end

    desc "upload", "Upload a specific file to S3"
    method_option :file, aliases: "-f", desc: "File to upload"
    def upload
      file_name = options[:file]
      validate_file!(file_name)
      save_to_s3(file_name)
      Logger.success("File uploaded to S3.")
    end

    desc "download", "Download a file from S3"
    method_option :file, aliases: "-f", desc: "File to download"
    def download
      file_name = options[:file]
      validate_file!(file_name, should_exist: false)
      load_from_s3_if_missing(file_name)
      Logger.success("File downloaded from S3.")
    end

    desc "list", "List all dumps"
    def list
      list = Backy::List.new.call
      list.each { |item| say "#{item.local? ? "local" : "     "} #{item.remote? ? "remote" : "      "} : #{item.dump_file}", :yellow }
      say_instructions_if_any(list)
    end

    desc "restore", "Restore a database from a dump"
    method_option :file, aliases: "-f", desc: "File to restore from"
    def restore
      file_name = find_file_for_restore(options[:file])
      pg_restore(load_from_s3_if_missing(file_name)) if file_name
      Logger.success("Database restored from #{file_name}.")
    end

    private

    def validate_file!(file_name, should_exist: true)
      if file_name.nil? || (should_exist ? !File.exist?(file_name) : File.exist?(file_name))
        Logger.error("Invalid file specified.")
        exit 1
      end
    end

    def find_file_for_restore(template_file_name)
      file_name = Backy::List.new.call.reverse.find { |item| item.dump_file.starts_with?(template_file_name) }&.dump_file if template_file_name.present?
      Logger.info "Please set the file to restore from." if file_name.nil?
      file_name
    end

    def say_instructions_if_any(list)
      return unless list.any?
      Logger.info("\nTo restore a backup, run:")
      Logger.log("  backy restore --file FILE_NAME")
    end

    def load_from_s3_if_missing(file_name)
      Backy::S3Load.new(file_name: file_name).call
    end

    def save_to_s3(file_name)
      Backy::S3Save.new(file_name: file_name).call
    end
  end
end

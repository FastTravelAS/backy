module DB
  module Backup
    class List < ApplicationService
      def call
        locals = Set.new(Dir.glob(dump_wildcard))
        remotes = Set.new(S3List.call)

        (locals + remotes).sort.each do |file|
          puts "#{file.in?(locals) ? "local" : "     "} #{file.in?(remotes) ? "remote" : "      "} : #{file}"
        end
      end

      private

      def dump_wildcard
        PgDump::DUMP_DIR + "/*"
      end
    end
  end
end

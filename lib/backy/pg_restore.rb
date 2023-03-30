module Backy
  class PgRestore < Base
    include DBConfig

    def initialize(file_name:)
      @file_name = file_name
    end

    def call
      terminate_connection_sql = "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{database}' AND pid <> pg_backend_pid();"
      cmd = "(#{pg_password}psql -c \"#{terminate_connection_sql};\" #{pg_credentials} #{database}; #{pg_password}dropdb #{pg_credentials} #{database}; #{pg_password}createdb #{pg_credentials} #{database}; gunzip -c #{file_name} | #{pg_password}psql #{pg_credentials} -q -d #{database}) 2>&1 >> #{LOG_FILE}"

      print "Restoring #{database} from #{file_name} ... "

      if system(cmd)
        puts "done"
      else
        puts "error. See #{LOG_FILE}"
      end
    end

    private

    attr_reader :file_name
  end
end

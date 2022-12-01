module Rubynor
  module DB
    module Backup
      class PgDump < Base
        include AppConfig
        include DBConfig

        DUMP_DIR = "db/dump"
        DUMP_CMD_OPTS = "--no-acl --no-owner --no-subscriptions --no-publications --exclude-table=awsdms_ddl_audit"

        def call
          FileUtils.mkdir_p(DUMP_DIR)

          dump_file = "#{DUMP_DIR}/#{database}_#{whoami}@#{hostname}_#{Time.zone.now.strftime("%Y%m%d_%H%M%S")}.sql.gz"

          cmd = "(#{pg_password}pg_dump #{pg_credentials} #{database} #{DUMP_CMD_OPTS} | gzip -9 > #{dump_file}) 2>&1 >> #{LOG_FILE}"

          print "Saving to #{dump_file} ... "

          if system(cmd)
            puts "done"
          else
            puts "error. See #{LOG_FILE}"

            return
          end

          dump_file
        end

        private

        def hostname = @hostname ||= `hostname`.strip

        def whoami = @whoami ||= `whoami`.strip
      end
    end
  end
end

module Backy
  class PgDump
    include Db
    include AppConfig

    DUMP_DIR = "db/dump"
    DUMP_CMD_OPTS = "--no-acl --no-owner --no-subscriptions --no-publications --exclude-table=awsdms_ddl_audit"

    def call
      FileUtils.mkdir_p(DUMP_DIR)

      dump_file = "#{DUMP_DIR}/#{database}_#{whoami}@#{hostname}_#{Time.zone.now.strftime("%Y%m%d_%H%M%S")}.sql.gz"

      cmd = "(#{pg_password_env}pg_dump #{pg_credentials} #{database} #{DUMP_CMD_OPTS} | gzip -9 > #{dump_file}) 2>&1 >> #{log_file}"

      print "Saving to #{dump_file} ... "

      if system(cmd)
        puts "done"
      else
        puts "error. See #{log_file}"

        return
      end

      dump_file
    end

    private

    def hostname
      @hostname ||= `hostname`.strip
    end

    def whoami
      @whoami ||= `whoami`.strip
    end
  end
end

module Backy
  module DBConfig
    LOG_FILE = "log/db_backup.log"

    private

    def host = @host ||= ActiveRecord::Base.connection_db_config.configuration_hash[:host]

    def port = @port ||= ActiveRecord::Base.connection_db_config.configuration_hash[:port]

    def database = @database ||= ActiveRecord::Base.connection_db_config.configuration_hash[:database]

    def username = @username ||= ActiveRecord::Base.connection_db_config.configuration_hash[:username]

    def password = @password ||= ActiveRecord::Base.connection_db_config.configuration_hash[:password]

    def pg_password = @pg_password ||= password.present? ? "PGPASSWORD='#{password}' " : ""

    def pg_credentials
      args_string = ""

      args_string << " -U #{username}" if username.present?
      args_string << " -h #{host}" if host.present?
      args_string << " -p #{port}" if port.present?

      args_string
    end
  end
end

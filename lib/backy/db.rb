require 'forwardable'

module Backy
  module Db
    extend Forwardable

    private

    def_delegator "Backy.configuration", :pg_host, :host
    def_delegator "Backy.configuration", :pg_port, :port
    def_delegator "Backy.configuration", :pg_database, :database
    def_delegator "Backy.configuration", :pg_username, :username
    def_delegator "Backy.configuration", :pg_password, :password

    def pg_password_env
      password.present? ? "PGPASSWORD='#{password}' " : ""
    end

    def pg_credentials
      args_string = ""

      args_string << " -U #{username}" if username.present?
      args_string << " -h #{host}" if host.present?
      args_string << " -p #{port}" if port.present?

      args_string
    end

    def use_pg_dump_option_if_supported(option)
      system("pg_dump --help | grep -q -- '#{option}'") ? option : ""
    end
  end
end

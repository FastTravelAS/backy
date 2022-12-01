RSpec.shared_context "PG Config", shared_context: :metadata do
  let(:host) { ActiveRecord::Base.connection_db_config.configuration_hash[:host] }
  let(:port) { ActiveRecord::Base.connection_db_config.configuration_hash[:port] }
  let(:database) { ActiveRecord::Base.connection_db_config.configuration_hash[:database] }
  let(:username) { ActiveRecord::Base.connection_db_config.configuration_hash[:username] }
  let(:password) { ActiveRecord::Base.connection_db_config.configuration_hash[:password] }
  let(:pg_password) { password.present? ? "PGPASSWORD='#{password}' " : "" }
  let(:terminate_connection_sql) { "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{database}' AND pid <> pg_backend_pid();" }
  let(:pg_credentials) do
    args_string = ""

    args_string << " -U #{username}" if username.present?
    args_string << " -h #{host}" if host.present?
    args_string << " -p #{port}" if port.present?

    args_string
  end
end

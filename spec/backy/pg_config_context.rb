RSpec.shared_context "with config", shared_context: :metadata do
  let(:pg_host) { "localhost" }
  let(:pg_port) { "5432" }
  let(:pg_password) { "postgres" }
  let(:pg_username) { "postgres" }
  let(:pg_database) { "test" }
  before do
    Backy.configure do |config|
      config.use_parallel = false
      config.pause_replication = false
      config.pg_host = pg_host
      config.pg_port = pg_port
      config.pg_database = pg_database
      config.pg_username = pg_username
      config.pg_password = pg_password

      config.s3_access_key = "test-access-key"
      config.s3_secret = "test-secret-key"
      config.s3_region = "eu-central-1"
      config.s3_bucket = "test-bucket-name"
      config.s3_prefix = "./db/dump/"
    end
  end

  let(:pg_password_env) { "PGPASSWORD='#{pg_password}' " }
  let(:terminate_connection_sql) { "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{pg_database}' AND pid <> pg_backend_pid();" }
  let(:pg_credentials) { " -U #{pg_username} -h #{pg_host} -p #{pg_port}" }
end

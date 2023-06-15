require "./spec/backy/pg_config_context"

RSpec.describe Backy::PgRestore do
  subject { -> { described_class.new(**params).call } }

  include_context "PG Config"

  let(:params) { {file_name: example_file} }
  let(:example_file) { "example/file.sql.gz" }
  let(:log_file) { "log/db_backup.log" }
  let(:cmd) { "(#{pg_password_env}psql -c \"#{terminate_connection_sql};\" #{pg_credentials} #{pg_database}; #{pg_password_env}dropdb #{pg_credentials} #{pg_database}; #{pg_password_env}createdb #{pg_credentials} #{pg_database}; gunzip -c #{example_file} | #{pg_password_env}psql #{pg_credentials} -q -d #{pg_database}) 2>&1 >> #{log_file}" }

  before do
    expect_any_instance_of(Object).to receive(:system).with(cmd).and_return(true)
  end

  it "calls psql with expected arguments" do
    expect { subject.call }.to output("Restoring #{pg_database} from example/file.sql.gz ... done\n").to_stdout
  end
end

require "./spec/rubynor/db/backup/pg_config_context"

RSpec.describe Rubynor::DB::Backup::PgRestore do
  subject { -> { described_class.call(**params) } }

  include_context "PG Config"

  let(:params) { {file_name: example_file} }
  let(:example_file) { "example/file.sql.gz" }
  let(:log_file) { "log/db_backup.log" }
  let(:cmd) { "(#{pg_password}psql -c \"#{terminate_connection_sql};\" #{pg_credentials} #{database}; #{pg_password}dropdb #{pg_credentials} #{database}; #{pg_password}createdb #{pg_credentials} #{database}; gunzip -c #{example_file} | #{pg_password}psql #{pg_credentials} -q -d #{database}) 2>&1 >> #{log_file}" }

  before do
    expect_any_instance_of(Object).to receive(:system).with(cmd).and_return(true)
  end

  it "calls psql with expected arguments" do
    expect { subject.call }.to output("Restoring #{database} from example/file.sql.gz ... done\n").to_stdout
  end
end

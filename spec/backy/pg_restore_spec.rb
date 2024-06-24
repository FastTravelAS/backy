require "./spec/backy/pg_config_context"
require "spec_helper"
require "fileutils"
require "timecop"

RSpec.describe Backy::PgRestore do
  subject(:pg_restore) { described_class.new(**params) }

  include_context "with config"

  let(:params) { {file_name: example_file} }
  let(:example_file) { "example/file.sql.gz" }
  let(:log_file) { "log/backy.log" }
  let(:terminate_connection_sql) { "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{pg_database}' AND pid <> pg_backend_pid();" }
  let(:cmd) { "(#{pg_password_env}psql -c \"#{terminate_connection_sql};\" #{pg_credentials} #{pg_database}; #{pg_password_env}dropdb #{pg_credentials} #{pg_database}; #{pg_password_env}createdb #{pg_credentials} #{pg_database}; gunzip -c #{example_file} | #{pg_password_env}psql #{pg_credentials} -q -d #{pg_database}) 2>&1 >> #{log_file}" }

  before do
    allow(FileUtils).to receive(:mkdir_p).and_call_original
    allow(FileUtils).to receive(:rm_rf).and_call_original
    allow(Backy::Logger).to receive(:log).and_call_original
    allow(Backy::Logger).to receive(:success).and_call_original

    pg_restore_instance = described_class.new(**params)
    allow(pg_restore_instance).to receive(:system).with("which pigz > /dev/null 2>&1").and_return(false)
    allow(pg_restore_instance).to receive(:system).with(cmd).and_return(true)
    allow(pg_restore_instance).to receive(:system).and_return(true)
    allow(described_class).to receive(:new).with(**params).and_return(pg_restore_instance)

    Backy::Logger.instance_variable_set(:@log_messages, []) # Clear log messages
  end

  it "calls psql with expected arguments" do
    expect { pg_restore.call }.not_to raise_error
  end

  it "logs the correct messages" do
    pg_restore.call

    log_messages = Backy::Logger.log_messages
    expect(log_messages).to include("Pigz not installed or system is not multicore")
    expect(log_messages).to include("Using plain text restore")
    expect(log_messages).to include("Restoring #{pg_database} from #{example_file} ...")
  end
end

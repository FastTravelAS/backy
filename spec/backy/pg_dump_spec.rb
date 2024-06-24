require "spec_helper"
require "fileutils"
require "timecop"

RSpec.describe Backy::PgDump do
  let(:timestamp) { Time.new(2024, 6, 24, 8, 58, 17) }
  let(:whoami) { "test" }
  let(:hostname) { "test-host" }
  let(:database) { "test" }
  let(:dump_file) { "db/dump/#{database}_#{whoami}@#{hostname}_#{timestamp.strftime("%Y%m%d_%H%M%S")}.sql.gz" }
  let(:log_file) { "./log/backy.log" }
  let(:cmd) { "(PGPASSWORD='postgres' pg_dump -h localhost -U postgres -p 5432 #{database} --no-acl --no-owner --no-subscriptions --no-publications | gzip -9 > #{dump_file}) 2>&1 >> #{log_file}" }
  let(:pg_dump) { described_class.new }

  before do
    Timecop.freeze(timestamp)

    allow(FileUtils).to receive(:mkdir_p).with(described_class::DUMP_DIR)
    allow(pg_dump).to receive(:hostname).and_return(hostname)
    allow(pg_dump).to receive(:whoami).and_return(whoami)
    allow(pg_dump).to receive(:database).and_return(database)
    allow(pg_dump).to receive(:pg_password_env).and_return("PGPASSWORD='postgres' ")
    allow(pg_dump).to receive(:pg_credentials).and_return("-h localhost -U postgres -p 5432")
    allow(pg_dump).to receive(:system).and_return(true)
    allow(pg_dump).to receive(:execute_sql).and_return([true, "f"])

    Backy::Logger.instance_variable_set(:@log_messages, []) # Clear log messages
  end

  after do
    Timecop.return
  end

  it "calls system with the correct pg_dump command for single core backup" do
    allow(pg_dump).to receive(:system).with(cmd).and_return(true)

    pg_dump.call

    expect(pg_dump).to have_received(:system).with(cmd)
  end

  it "logs the correct messages" do
    pg_dump.call

    log_messages = Backy::Logger.log_messages
    expect(log_messages).to include("Starting backy for test")
    expect(log_messages).to include("Using single core dump")
    expect(log_messages).to include("Saving to #{dump_file} ... ")
  end

  it "checks if the database is a replica" do
    allow(pg_dump).to receive(:execute_sql).with("SELECT pg_is_in_recovery();").and_return([true, "t"])
    expect(pg_dump.send(:replica?)).to be true
  end

  it "checks if the database is not a replica" do
    allow(pg_dump).to receive(:execute_sql).with("SELECT pg_is_in_recovery();").and_return([true, "f"])
    expect(pg_dump.send(:replica?)).to be false
  end
end

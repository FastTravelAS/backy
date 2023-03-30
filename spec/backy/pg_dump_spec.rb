require "./spec/backy/pg_config_context"

RSpec.describe Backy::PgDump do
  subject { -> { described_class.call(**params) } }

  include_context "PG Config"

  let(:params) { {} }
  let(:timestamp) { Time.zone.now }
  let(:whoami) { "test" }
  let(:hostname) { "test-host" }
  let(:dump_file) { "#{described_class::DUMP_DIR}/#{database}_#{whoami}@#{hostname}_#{timestamp.strftime("%Y%m%d_%H%M%S")}.sql.gz" }
  let(:log_file) { "log/db_backup.log" }
  let(:cmd) { "(#{pg_password}pg_dump #{pg_credentials} #{database} #{described_class::DUMP_CMD_OPTS} | gzip -9 > #{dump_file}) 2>&1 >> #{log_file}" }

  before do
    Timecop.freeze(timestamp)
    allow(FileUtils).to receive(:mkdir_p).with(described_class::DUMP_DIR)
    expect_any_instance_of(Object).to receive(:system).with(cmd).and_return(true)
    allow_any_instance_of(described_class).to receive(:whoami).and_return(whoami)
    allow_any_instance_of(described_class).to receive(:hostname).and_return(hostname)
  end

  it "calls system with pg_dump command" do
    expect { subject.call }.to output("Saving to #{dump_file} ... done\n").to_stdout
  end
end

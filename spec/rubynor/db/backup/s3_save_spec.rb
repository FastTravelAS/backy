# frozen_string_literal: true

describe DB::Backup::S3Save do
  subject { -> { described_class.call(**params) } }

  let(:params) { {file_name: example_file} }

  let(:example_file) { "example/file.sql.gz" }
  let(:example_body) { "example body" }
  let(:s3) { double }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    allow(s3).to receive(:put_object).with(hash_including(key: example_file, body: example_body))
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(example_file).and_return(true)
    allow(File).to receive(:open).with(example_file, "rb").and_yield(example_body)
  end

  it "calls the S3 service" do
    expect { subject.call }.to output("Sending example/file.sql.gz to S3 ... done\n").to_stdout

    expect(s3).to have_received(:put_object).with(hash_including(key: example_file, body: example_body))
  end
end

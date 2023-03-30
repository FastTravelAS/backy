# frozen_string_literal: true

RSpec.describe Backy::S3Load do
  subject { -> { described_class.call(**params) } }

  let(:params) { {file_name: example_file} }

  let(:example_file) { "example/file.sql.gz" }
  let(:s3) { double }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    allow(File).to receive(:rename).with(anything, example_file).and_return(true)
    allow(s3).to receive(:get_object).with(hash_including(key: example_file))
  end

  it "calls the S3 and returns the file name" do
    expect { expect(subject.call).to eq(example_file) }.to output("Loading example/file.sql.gz from S3 ... done\n").to_stdout
  end
end

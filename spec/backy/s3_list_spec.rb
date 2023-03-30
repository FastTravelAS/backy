# frozen_string_literal: true

RSpec.describe Backy::S3List do
  subject { -> { described_class.call(**params) } }

  let(:params) { {} }

  let(:s3) { double }
  let(:example_paths) { ["example/file.sql.gz"] }
  let(:example_list) { OpenStruct.new(contents: example_paths.map { |path| OpenStruct.new(key: path) }) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    allow(s3).to receive(:list_objects).and_return(example_list)
    allow(ENV).to receive(:key?).with("S3_REGION").and_return(true)
    allow(ENV).to receive(:key?).with("S3_ACCESS_KEY").and_return(true)
    allow(ENV).to receive(:key?).with("S3_SECRET").and_return(true)
    allow(ENV).to receive(:key?).with("S3_BUCKET").and_return(true)
  end

  it "returns the file list" do
    expect(subject.call).to eq(example_paths)
  end
end

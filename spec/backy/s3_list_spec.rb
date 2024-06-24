require "./spec/backy/pg_config_context"

RSpec.describe Backy::S3List do
  subject(:s3_list) { described_class.new(**params) }

  include_context "with config"

  let(:params) { {} }

  let(:s3) { double }
  let(:example_paths) { ["example/file.sql.gz"] }
  let(:example_list) { OpenStruct.new(contents: example_paths.map { |path| OpenStruct.new(key: path) }) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3)
    allow(s3).to receive(:list_objects).and_return(example_list)
  end

  it "returns the file list" do
    expect(s3_list.call).to eq(example_paths)
  end
end

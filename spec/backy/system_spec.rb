require "rails_helper"
require "zlib"
require "stringio"

RSpec.describe "Backy backup system", type: :system do
  let!(:dummy_app) { File.expand_path("spec/dummy") }

  before do
    Dir.chdir(dummy_app) do
      system("./bin/rails db:drop db:create db:schema:load db:seed")
    end
  end

  after do
    # clean up the dump directory
    Dir.chdir(dummy_app) do
      FileUtils.rm_rf("./db/dump")
    end
  end

  it "backs up a seeded database" do
    Dir.chdir(dummy_app) do
      system("./bin/rails backy:dump")

      # Find the latest backup file
      dump_dir = "./db/dump"
      latest_file = Dir.glob("#{dump_dir}/*.gz").max_by { |f| File.mtime(f) }

      # Check the backup file exists and is not empty
      expect(File).to exist(latest_file)
      expect(File.size(latest_file)).to be_positive

      content = Zlib::GzipReader.new(StringIO.new(File.read(latest_file))).read
      occurrences_of_string = content.scan("BackyPost").count
      expect(occurrences_of_string).to eq(5)
    end
  end
end
require "spec_helper"
require "fileutils"

RSpec.describe Backy::Configuration do
  before do
    # Reset configuration
    Backy.instance_variable_set(:@configuration, described_class.new)
  end

  after do
    # Clean up environment variables and temp files
    ENV.delete("PG_HOST")
    ENV.delete("PG_PORT")
    ENV.delete("PG_DATABASE")
    ENV.delete("BACKY_USE_PARALLEL")
    ENV.delete("BACKY_PAUSE_REPLICATION")
    FileUtils.rm_f(".backyrc")
  end

  context "when configured by block" do
    before do
      Backy.configure do |config|
        config.pg_host = "test_host_1337"
        config.pg_port = 1337
        config.pg_database = "backy_db"
        config.use_parallel = true
        config.pause_replication = false
      end
    end

    it "sets the configuration correctly" do
      expect(Backy.configuration.pg_host).to eq("test_host_1337")
      expect(Backy.configuration.pg_port).to eq(1337)
      expect(Backy.configuration.pg_database).to eq("backy_db")
      expect(Backy.configuration.use_parallel).to be(true)
      expect(Backy.configuration.pause_replication).to be(false)
    end
  end

  context "when configured by ENV" do
    before do
      ENV["PG_HOST"] = "env_host"
      ENV["PG_PORT"] = "5432"
      ENV["PG_DATABASE"] = "env_db"
      ENV["BACKY_USE_PARALLEL"] = "true"
      ENV["BACKY_PAUSE_REPLICATION"] = "false"
      Backy.configuration.load
    end

    it "sets the configuration correctly" do
      expect(Backy.configuration.pg_host).to eq("env_host")
      expect(Backy.configuration.pg_port).to eq("5432")
      expect(Backy.configuration.pg_database).to eq("env_db")
      expect(Backy.configuration.use_parallel).to be(true)
      expect(Backy.configuration.pause_replication).to be(false)
    end
  end

  context "when configured by rc file" do
    before do
      File.write(".backyrc", <<~YAML)
        shared:
          pg_host: "rc_file_host"
          pg_port: 15432
          pg_database: "rc_file_db"
          use_parallel: true
          pause_replication: false
        production:
          pg_host: "prod_host"
          pg_port: 5433
      YAML
      Backy.configuration.environment = "production"
      Backy.configuration.load
    end

    it "sets the shared and environment-specific configuration correctly" do
      expect(Backy.configuration.pg_host).to eq("prod_host")
      expect(Backy.configuration.pg_port).to eq(5433)
      expect(Backy.configuration.pg_database).to eq("rc_file_db")
      expect(Backy.configuration.use_parallel).to be(true)
      expect(Backy.configuration.pause_replication).to be(false)
    end
  end

  context "when database is configured using db url" do
    before do
      File.write(".backyrc", <<~YAML)
        shared:
          pg_url: "postgres://username:password@localhost:5432/database_name"
      YAML
      Backy.configuration.load
    end

    it "sets the configuration correctly" do
      expect(Backy.configuration.pg_host).to eq("localhost")
      expect(Backy.configuration.pg_port).to eq(5432)
      expect(Backy.configuration.pg_username).to eq("username")
      expect(Backy.configuration.pg_password).to eq("password")
      expect(Backy.configuration.pg_database).to eq("database_name")
    end
  end
end

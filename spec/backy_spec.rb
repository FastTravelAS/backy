# frozen_string_literal: true

RSpec.describe Backy do
  it "has a version number" do
    expect(Backy::VERSION).not_to be_nil
  end

  it "can be configured" do
    Backy.configure do |config|
      config.pg_host = "test_host_1337"
      config.pg_port = 1337
      config.pg_database = "backy_db"
    end

    expect(Backy.configuration.pg_host).to eq("test_host_1337")
    expect(Backy.configuration.pg_port).to eq(1337)
    expect(Backy.configuration.pg_database).to eq("backy_db")
  end

  it "can be configured using a database url" do
    Backy.configure do |config|
      config.pg_url = "postgres://username:password@localhost:5432/database_name"
    end

    expect(Backy.configuration.pg_host).to eq("localhost")
    expect(Backy.configuration.pg_port).to eq(5432)
    expect(Backy.configuration.pg_username).to eq("username")
    expect(Backy.configuration.pg_password).to eq("password")
    expect(Backy.configuration.pg_database).to eq("database_name")
  end
end

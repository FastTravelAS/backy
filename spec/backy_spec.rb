# frozen_string_literal: true

RSpec.describe Backy do
  it "has a version number" do
    expect(Backy::VERSION).not_to be nil
  end

  it "can be configured" do
    Backy.configure do |config|
      config.host = "localhost"
      config.port = 1337
      config.database = "backy_db"
    end

    expect(Backy.configuration.port).to eq(1337)
  end
end

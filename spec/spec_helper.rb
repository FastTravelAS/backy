# frozen_string_literal: true

require "backy"
require "timecop"
require "active_support"
require "active_record"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Time.zone_default = Time.find_zone! "Europe/Stockholm"

db_config_file = File.open('config/database.yml')
db_config = YAML::load(db_config_file, aliases: true)

ActiveRecord::Base.establish_connection(db_config["test"])

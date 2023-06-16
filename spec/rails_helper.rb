ENV["RAILS_ENV"] = "test"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require_relative "./dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("./dummy/db/migrate", __dir__)]
require_relative "spec_helper"

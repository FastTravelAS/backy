ENV["RAILS_ENV"] = "test"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require_relative "../dummy/psql/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../dummy/psql/db/migrate", __dir__)]
require_relative "spec_helper"

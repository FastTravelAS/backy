require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module Psql
  class Application < Rails::Application

    config.active_record.legacy_connection_handling = false
    config.eager_load = false
  end
end

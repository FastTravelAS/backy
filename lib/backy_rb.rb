# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/integer/time"
require "active_support/core_ext/object/blank"

require_relative "backy/cli"
require_relative "backy/configuration"
require_relative "backy/app_config"
require_relative "backy/db"
require_relative "backy/list"
require_relative "backy/logger"
require_relative "backy/pg_dump"
require_relative "backy/pg_restore"
require_relative "backy/s3"
require_relative "backy/s3_list"
require_relative "backy/s3_load"
require_relative "backy/s3_save"
require_relative "backy/version"

require_relative "backy/railtie" if defined?(Rails::Railtie)

module Backy
  class Error < StandardError; end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup
    Logger.log("Setting up Backy...")
    configuration.load
    setup_logging
  end

  def self.setup_logging
    log_file = configuration.log_file
    log_dir = File.dirname(log_file)
    FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
  end
end

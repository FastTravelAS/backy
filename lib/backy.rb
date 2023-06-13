# frozen_string_literal: true

require "active_support/core_ext/integer/time"

require_relative "backy/app_config"
require_relative "backy/db_config"
require_relative "backy/base"
require_relative "backy/list"
require_relative "backy/pg_dump"
require_relative "backy/pg_restore"
require_relative "backy/s3_config"
require_relative "backy/s3_list"
require_relative "backy/s3_load"
require_relative "backy/s3_save"
require_relative "backy/version"

require_relative "backy/railtie" if defined?(Rails::Railtie)

module Backy
  class Error < StandardError; end
  # Your code goes here...
end

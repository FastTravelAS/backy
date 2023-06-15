require 'forwardable'

module Backy
  module AppConfig
    extend Forwardable

    private

    def_delegators "Backy.configuration", :app_name, :environment, :log_file
  end
end

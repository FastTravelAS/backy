module Backy
  class Railtie < Rails::Railtie
    initializer "railtie.configure_rails_initialization" do
      Backy.configure do |config|
        config.pg_host = ActiveRecord::Base.connection_db_config.configuration_hash[:host]
        config.pg_port = ActiveRecord::Base.connection_db_config.configuration_hash[:port]
        config.pg_database = ActiveRecord::Base.connection_db_config.configuration_hash[:database]
        config.pg_username = ActiveRecord::Base.connection_db_config.configuration_hash[:username]
        config.pg_password = ActiveRecord::Base.connection_db_config.configuration_hash[:password]
        config.app_name = Rails.application.class.name.split("::").first.underscore
        config.environment = Rails.env
      end
    end

    rake_tasks do
      load "tasks/backy_tasks.rake"
    end
  end
end

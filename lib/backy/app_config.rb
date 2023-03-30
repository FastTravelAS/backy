module Backy
  module AppConfig
    def app_name = @app_name ||= Rails.application.class.name.split("::").first.underscore

    def environment = @environment ||= Rails.env
  end
end

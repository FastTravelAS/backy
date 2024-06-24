require "thor"

module Backy
  class Logger
    @log_messages = []

    # Logs a message with the specified color using Thor's shell
    def self.log(message, color = nil)
      @log_messages << message
      say("[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}\n", color)
    end

    def self.success(message)
      log(message, :green)
    end

    def self.info(message)
      log(message, :blue)
    end

    def self.warn(message)
      log(message, :yellow)
    end

    def self.error(message)
      log(message, :red)
    end

    def self.say(message, color = nil)
      thor_shell.say(message, color)
    end

    def self.log_messages
      @log_messages
    end

    private_class_method def self.thor_shell
      @thor_shell ||= Thor::Base.shell.new
    end
  end
end

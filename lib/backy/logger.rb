require 'thor'

module Backy
  class Logger
    # Logs a message with the specified color using Thor's shell
    def self.log(message, color = nil)
      thor_shell = Thor::Base.shell.new
      thor_shell.say("[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}", color)
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
  end
end

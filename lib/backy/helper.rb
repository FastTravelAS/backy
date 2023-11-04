module Backy
  module Helper
    def log_message(message)
      puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}"
    end
  end
end
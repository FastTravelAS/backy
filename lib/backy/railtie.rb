module Backy
  class Railtie < Rails::Railtie
    rake_tasks do
      load "lib/tasks/database.rake"
    end
  end
end

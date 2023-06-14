module Backy
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/backy_tasks.rake"
    end
  end
end

module Sidekiq
  module Monitor
    class Railtie < ::Rails::Railtie
      rake_tasks do
        require 'sidekiq/monitor/tasks'
      end
    end
  end
end

module Sidekiq
  module Monitor
    module Counters
      class Worker < Base
        def self.namespace
          'monitor:workers'
        end

        def self.events_column
          'worker_class'
        end
      end
    end
  end
end

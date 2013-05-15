module Sidekiq
  module Monitor
    module Counters
      class Queue < Base
        def self.namespace
          'monitor:queues'
        end

        def self.events_column
          'queue'
        end
      end
    end
  end
end

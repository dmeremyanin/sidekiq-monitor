module Sidekiq
  module Monitor
    class Middleware
      def call(worker, message, queue)
        event = Sidekiq::Monitor::Event.create_or_update_with(worker, message, queue)

        begin
          yield
          event.finish
        rescue Exception => e
          event.error(e)
          raise
        end
      end
    end
  end
end

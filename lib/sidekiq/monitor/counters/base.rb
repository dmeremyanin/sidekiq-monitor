module Sidekiq
  module Monitor
    module Counters
      class Base
        attr_reader :name, :enqueued, :runtime

        def initialize(name, enqueued = nil, runtime = nil)
          @name, @enqueued, @runtime = name, enqueued, runtime
        end

        def self.namespace
          raise NotImplementedError
        end

        def self.events_column
          raise NotImplementedError
        end

        def self.all(force = false)
          update if force || update_needed?

          Sidekiq.redis do |conn|
            names.inject({}) do |memo, name|
              memo[name] = conn.hgetall(new(name).key)
              memo
            end
          end
        end

        def self.names
          Sidekiq.redis do |conn|
            conn.smembers(namespace).sort
          end
        end

        def self.update
          events = Sidekiq::Monitor::Event
          Sidekiq.redis { |conn| conn.set("#{namespace}:updated_at", Time.now) }
          events.connection.execute("SELECT #{events_column}, COUNT(id), AVG(runtime) FROM #{events.table_name} \
            GROUP BY #{events_column}").values.each do |name, enqueued, runtime|

            new(name, enqueued, runtime).save
          end
        end

        def self.update_needed?
          updated_at.nil? || updated_at.advance(seconds: 10).past?
        end

        def self.updated_at
          Sidekiq.redis { |conn| Time.parse conn.get("#{namespace}:updated_at") }
        rescue
        end

        def key
          "#{self.class.namespace}:#{name}"
        end

        def save
          Sidekiq.redis do |conn|
            conn.pipelined do
              conn.hmset(key, :enqueued, enqueued, :runtime, runtime)
              conn.sadd(self.class.namespace, name)
            end
          end
        end
      end
    end
  end
end

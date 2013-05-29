# encoding: utf-8
module Sidekiq
  module Monitor
    class Event < ActiveRecord::Base
      self.table_name = 'sidekiq_monitor_events'

      serialize :exception, Hash
      serialize :args,      Array

      scope :recent,  -> { order(:id).reverse_order }

      before_save :assign_revision

      def self.create_or_update_with(worker, message, queue)
        transaction do
          find_or_initialize_by_jid(message['jid']).tap do |e|
            e.started_at   = Time.now
            e.retry_count  = message['retry_count'].to_i + 1 if message.has_key?('retry_count')
            e.worker_class = worker.class.name
            e.args  = message['args']
            e.queue = queue
            e.save
          end
        end
      end

      def finished?
        !!finished_at
      end

      def finished_at
        if runtime?
          started_at + runtime.seconds
        end
      end

      def finish
        update_attribute(:runtime, Time.now - started_at)
      end

      def error(exception)
        update_attribute(:exception, {
          class:     exception.class.name,
          backtrace: exception.backtrace,
          message:   exception.message
        })
      end

      protected

      def assign_revision
        self.revision = Sidekiq::Monitor.current_revision
      end
    end
  end
end

# encoding: utf-8
module Sidekiq
  module Monitor
    class Event < ActiveRecord::Base
      self.table_name = 'sidekiq_monitor_events'

      serialize :exception, Hash
      serialize :args,      Array

      scope :recent,     lambda { order(:id).reverse_order }
      scope :older_than, lambda { |time| where(arel_table[:created_at].lt(time)) }

      before_save :assign_revision

      class << self

        def create_or_update_with(worker, message, queue)
          transaction do
            find_or_initialize_by_id(message['monitor_id']).tap do |e|
              e.started_at   = Time.now
              e.retry_count  = message['retry_count'].to_i + 1 if message.has_key?('retry_count')
              e.worker_class = worker.class.name
              e.args  = message['args']
              e.jid   = message['jid']
              e.queue = queue
              e.save

              message['monitor_id'] ||= e.id
            end
          end
        end

        def find_or_initialize_by_id(id, options = {}, &block)
          id.nil? ? new(options, &block) : super
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

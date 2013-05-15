require 'rails/generators'

module Sidekiq
  module Monitor
    class MigrationGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc 'Generates migration for Sidekiq::Monitor::Event model'

      def self.source_root
        File.join(File.dirname(__FILE__), 'templates')
      end

      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime('%Y%m%d%H%M%S').to_i.succ.to_s
        else
          '%.3d' % current_migration_number(dirname).succ
        end
      end

      def create_migration_file
        migration_template 'migration.rb', 'db/migrate/create_sidekiq_monitor_events.rb'
      end
    end
  end
end

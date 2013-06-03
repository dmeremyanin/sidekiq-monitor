namespace :sidekiq do
  namespace :monitor do
    desc 'Sidekiq-monitor events cleanup'
    task :cleanup => :environment do
      ttl = Sidekiq::Monitor.events_ttl || 3.weeks
      Sidekiq::Monitor::Event.older_than(ttl.ago).delete_all
    end
  end
end

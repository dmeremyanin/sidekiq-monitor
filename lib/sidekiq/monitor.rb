require 'sidekiq'
require 'sidekiq/web'
require 'will_paginate'
require 'will_paginate/view_helpers/sinatra'

require 'sidekiq/monitor/version'
require 'sidekiq/monitor/models/event'
require 'sidekiq/monitor/counters/base'
require 'sidekiq/monitor/counters/queue'
require 'sidekiq/monitor/counters/worker'
require 'sidekiq/monitor/middleware'
require 'sidekiq/monitor/railtie'
require 'sidekiq/monitor/web/paginate_renderer'
require 'sidekiq/monitor/web'

module Sidekiq
  module Monitor
    extend self

    include ActiveSupport::Configurable

    config_accessor :events_ttl, :github_repo

    def current_revision
      @current_revision ||= begin
        `git rev-parse HEAD`.strip
      end
    end
  end
end

Sidekiq::Web.helpers  WillPaginate::Sinatra::Helpers
Sidekiq::Web.register Sidekiq::Monitor::Web
Sidekiq::Web.tabs['Monitor'] = 'monitor'

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Monitor::Middleware
  end
end

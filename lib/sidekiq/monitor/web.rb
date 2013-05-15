module Sidekiq
  module Monitor
    module Web
      def self.registered(app)
        app.instance_eval do
          set :views, [ *views, File.expand_path('views', File.dirname(__FILE__)) ].flatten

          helpers do
            def time_with_sec(time)
              "#{time.to_f.round(3)} sec"
            end

            def link_to_tree(revision)
              if repo = Sidekiq::Monitor.github_repo
                %(<a href="https://github.com/#{repo}/tree/#{revision}">#{revision[0..9]}</a>)
              else
                revision[0..9]
              end
            end

            def find_template(views, name, engine, &block)
              Array(views).each { |v| super(v, name, engine, &block) }
            end
          end

          get '/monitor' do
            @queues  = Sidekiq::Monitor::Counters::Queue.all
            @workers = Sidekiq::Monitor::Counters::Worker.all

            slim :'monitor/index'
          end

          get '/monitor/events' do
            @events = Sidekiq::Monitor::Event.recent.
              paginate(page: params[:page])

            slim :'monitor/events/index'
          end

          get '/monitor/queues/:name' do
            halt 404 unless params[:name]

            @name   = params[:name]
            @events = Sidekiq::Monitor::Event.where(queue: @name).recent.
              paginate(page: params[:page])

            slim :'monitor/events/index'
          end

          get '/monitor/workers/:name' do
            halt 404 unless params[:name]

            @name   = params[:name]
            @events = Sidekiq::Monitor::Event.where(worker_class: @name).recent.
              paginate(page: params[:page])

            slim :'monitor/events/index'
          end
        end
      end
    end
  end
end

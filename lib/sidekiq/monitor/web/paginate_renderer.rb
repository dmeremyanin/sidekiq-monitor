# encoding: utf-8
module Sidekiq
  module Monitor
    module Web
      class PaginateRenderer < WillPaginate::Sinatra::LinkRenderer
        protected

        def html_container(html)
          tag :div, tag(:ul, html), :class => 'pagination pagination-right'
        end

        def page_number(page)
          tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
        end

        def previous_page
          num = @collection.current_page > 1 && @collection.current_page - 1
          previous_or_next_page num, '«', 'previous_page'
        end

        def next_page
          num = @collection.current_page < total_pages && @collection.current_page + 1
          previous_or_next_page num, '»', 'next_page'
        end

        def previous_or_next_page(page, text, classname)
          tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
        end
      end
    end
  end
end

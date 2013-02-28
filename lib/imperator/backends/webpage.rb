require 'erb'

module Imperator
  module Backends
    class Webpage
      attr_accessor :compiler
      attr_reader :buffer

      attr_reader :survey_title
      attr_reader :survey_js
      attr_reader :survey_html
      attr_reader :elapsed

      alias_method :h, :survey_html
      alias_method :j, :survey_js

      def initialize
        @survey_js = []
        @survey_html = []
      end

      def write
        template = ERB.new(asset('page.html.erb'))
        puts template.result(binding)
      end

      def logue
        began = Time.now
        yield
        finished = Time.now
        @elapsed = finished - began
      end

      def survey(s)
        @survey_title = s.name

        h << "<article>"
        h << "<h1>#{survey_title}</h1>"
        yield
        h << "</article>"
      end
      
      def section(se, s)
        h << "<section>"
        h << "<header><h1>#{se.name}</h1></header>"
        h << "<ol>"
        yield
        h << "</ol>"
        h << "</section>"
      end

      def label(q, se)
        h << %Q{<li id="#{q.uuid}" data-ref="#{q.tag}" class="imperator-label">}
        h << %Q{<label>#{q.text}</label><li>}
        h << %Q{</li>}
      end

      def question(q, se)
        h << %Q{<li id="#{q.uuid}" data-ref="#{q.tag}" class="imperator-question">}
        h << "<label>#{q.text}</label>"
        h << "</li>"

        h << "<ol>"
        q.answers.each { |a| answer(a, q) }
        h << "</ol>"
      end

      def answer(a, q)
        h << %Q{<li id="#{a.uuid}" data-ref="#{a.tag}" class="imperator-answer">#{a.type}</li>}
      end

      def grid(q, se)
      end

      def group(q, se)
      end

      def repeater(q, se)
      end

      def asset(path)
        File.read(asset_path(path))
      end

      def asset_path(path)
        File.expand_path("../webpage/#{path}", __FILE__)
      end
    end
  end
end

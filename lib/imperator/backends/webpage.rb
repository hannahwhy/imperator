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
        @survey_js = ""
        @survey_html = ""
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
        ol { yield }
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

        answers(q)
      end

      def answers(q)
        case q.options[:pick]
        when :one then pick_one_answers(q)
        when :any then check_answers(q)
        else
          h << "(unhandled)"
        end
      end

      def pick_one_answers(q)
        case q.options[:display_type]
        when :slider then slider_answers(q)
        else radio_answers(q)
        end
      end

      def slider_answers(q)
        min = 0
        max = q.answers.length
        id = "slider-#{q.uuid}"

        h << %Q{
          <input type="range"
                 name="#{q.tag || q.uuid}"
                 id="#{id}"
                 data-q-uuid="#{q.uuid}"
                 class="imperator-answer imperator-answer-slider"
                 min="#{min}"
                 max="#{max}"
          </input>
        }

        values = q.answers.map { |a| a.text.inspect }.join(',')

        j << %Q{
          window.survey.sliderValues["#{id}"] = [#{values}];
        }
      end

      def radio_answers(q)
        ol do
          q.answers.each { |a| h << pick('radio', a, q) }
        end
      end

      def check_answers(q)
        ol do
          q.answers.each { |a| h << pick('checkbox', a, q) }
        end
      end

      def pick(type, a, q)
        %Q{<li>
             <input type="#{type}"
                    name="#{q.tag || q.uuid}"
                    id="#{a.uuid}"
                    data-ref="#{a.tag}"
                    data-q-uuid="#{q.uuid}"
                    class="imperator-answer imperator-answer-pick"
                    value="#{a.uuid}">
               #{a.text}
             </input>
           </li>
        }
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

      def ol
        h << "<ol>"
        yield
        h << "</ol>"
      end
    end
  end
end

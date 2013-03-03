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

      def prologue
      end

      def epilogue
      end

      def answer(n, level, parent, &block)
        case @qtype
        when :radio then pick_answer('radio', n, level, parent, block)
        when :checkbox then pick_answer('checkbox', n, level, parent, block)
        else yield
        end
      end

      def pick_answer(type, n, level, parent, block)
        name = n.parent.uuid

        h << %Q{
          <li>
        }

        if n.type == :other
          h << %Q{
            <label for="#{n.uuid}">Other</label>
            <input type="text" name="#{name}" id="#{n.uuid}" data-uuid="#{n.uuid}" data-tag="#{n.tag}" class="imperator-answer imperator-answer-pick-one imperator-answer-other">
          }

          j << %Q{
            $(function() {
                $("##{n.uuid}").focus(function() {
                  $('input[name="#{name}"]').prop('checked', '');
                });
            });
          }
        elsif n.type == :omit
          h << %Q{
            <input type="#{type}" name="#{name}" id="#{n.uuid}" data-uuid="#{n.uuid}" data-tag="#{n.tag}" value="#{n.uuid}" class="imperator-answer imperator-answer-pick-one imperator-answer-omit">
            <label for="#{n.uuid}">Omit</label>
          }

          j << %Q{
            $(function() {
                $("##{n.uuid}").change(function() {
                  var sel = $(this).prop('checked');

                  $('input[name="#{name}"]').prop('checked', !sel).prop('enabled', !sel)
                });
            });
          }
        else
          h << %Q{
            <input type="#{type}" name="#{name}" id="#{n.uuid}" data-uuid="#{n.uuid}" data-tag="#{n.tag}" value="#{n.uuid}" class="imperator-answer imperator-answer-pick-one">
            <label for="#{n.uuid}" data-i18n-context="#{n.tcontext}" data-i18n-key="#{n.uuid}" class="imperator-i18n">#{n.text}</label>
          }
        end

        block.call

        h << %Q{
            </input>
          </li>
        }
      end

      def condition(n, level, parent)
        yield
      end

      def dependency(n, level, parent)
        yield
      end

      def grid(n, level, parent)
        yield
      end

      def group(n, level, parent)
        yield
      end

      def label(n, level, parent)
        yield
      end

      def question(n, level, parent)
        h << %Q{
          <li data-uuid="#{n.uuid}" data-tag="#{n.tag}" class="imperator-question">
            <span data-i18n-context="#{n.tcontext}" data-i18n-key="#{n.uuid}" class="imperator-i18n">
              #{n.text}
            </span>
            <ol class="imperator-answers">
        }

        pick = n.options[:pick]

        @qtype = case pick
                 when :one then :radio
                 when :any then :checkbox
                 end

        yield

        h << %Q{
            </ol>
          </li>
        }
      end

      def repeater(n, level, parent)
        yield
      end

      def section(n, level, parent)
        h << %Q{
          <section data-uuid="#{n.uuid}" data-tag="#{n.tag}" class="imperator-section">
            <header>
              <h1 data-i18n-context="#{n.tcontext}" data-i18n-key="#{n.uuid}" class="imperator-i18n">#{n.name}</h1>
            </header>
            <ol class="imperator-questions">
        }

        yield

        h << %Q{
            </ol>
          </section>
        }
      end

      def survey(n, level, parent)
        start = Time.now

        h << %Q{
          <article data-uuid="#{n.uuid}" class="imperator-survey">
            <header>
              <h1 class="imperator-i18n" data-i18n-context="#{n.tcontext}" data-i18n-key="#{n.uuid}">#{n.name}</h1>
            </header>
        }

        yield

        h << %Q{
          </article>
        }

        done = Time.now
        @elapsed = done - start
      end

      def validation(n, level, parent)
        yield
      end

      def asset(path)
        File.read(asset_path(path))
      end

      def external_asset_path(path)
        "lib/imperator/backends/webpage/#{path}"
      end

      def asset_path(path)
        File.expand_path("../webpage/#{path}", __FILE__)
      end
    end
  end
end

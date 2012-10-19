require 'erb'

class String
  # Ripped from Facets Core.
  def margin(n=0)
    d = ((/\A.*\n\s*(.)/.match(self)) ||
        (/\A\s*(.)/.match(self)))[1]
    return '' unless d
    if n == 0
      gsub(/\n\s*\Z/,'').gsub(/^\s*[#{d}]/, '')
    else
      gsub(/\n\s*\Z/,'').gsub(/^\s*[#{d}]/, ' ' * n)
    end
  end
end

module Imperator
  module Backends
    class Ember
      attr_accessor :compiler
      attr_accessor :namespace
      attr_reader :buffer

      def initialize
        @buffer = ""
        @namespace ||= 'App'
        @serial = 0
        @refs = {}
      end

      def write
        puts @runtime
        puts @buffer
      end

      def logue
        generate_runtime

        @buffer << %Q{
          |#{v_surveys} = []
        }.margin

        newline

        yield
      end

      def survey(s)
        @buffer << %Q{
          |#{ref(s)} = #{c_survey}.create(name: "#{s.name}", uuid: "#{s.uuid}")
          |#{v_surveys}.push #{ref(s)}
        }.margin

        newline

        yield
      end

      def section(se, s)
        @buffer << %Q{
          |#{ref(se)} = #{c_section}.create(name: "#{se.name}", uuid: "#{se.uuid}")
          |#{ref(s)}.sections.push #{ref(se)}
        }.margin

        newline

        yield
      end

      def grid(q, se)
      end

      def group(q, se)
      end

      def repeater(q, se)
      end

      def question(q, se)
        @buffer << %Q{
          |#{ref(q)} = #{c_question}.create(text: "#{q.text}", uuid: "#{q.uuid}")
          |#{ref(se.survey)}.#{ref(q)} = #{ref(q)}
        }.margin

        newline

        q.answers.each { |a| answer(a, q) }
        q.dependencies.each { |d| dependency(d, q, se.survey) }
      end

      def label(l, se)
        @buffer << %Q{
          |#{ref(l)} = #{c_label}.create(text: "#{l.text}", uuid: "#{l.uuid}")
          |#{ref(se.survey)}.#{ref(l)} = #{ref(l)}
        }.margin

        newline
      end

      def answer(a, q)
        @buffer << %Q{
          |#{ref(q)}.answers.#{ref(a)} = #{c_answer}.create(text: "#{a.text}", uuid: "#{a.uuid}")
        }.margin

        newline
      end

      def dependency(d, q, survey)
        d.conditions.each { |c| condition(c, d, q) }

        constituents = d.conditions.map { |c| "'#{ref(c)}'" }.join(',')

        @buffer << %Q{
          |#{ref(q)}.#{ref(d)} = (->
          |).property(#{constituents})
          |
          |#{ref(survey)}.#{ref(d)} = #{ref(q)}.#{ref(d)}
        }.margin

        newline
      end

      def condition(c, d, q)
        @buffer << %Q{
          |#{ref(q)}.#{ref(d)}.#{ref(c)} = (->
          |).property()
        }.margin

        newline
      end

      def v_surveys
        toplevel_var('surveys')
      end

      def c_survey
        "#{namespace}.Survey"
      end

      def c_section
        "#{namespace}.SurveySection"
      end

      def c_question
        "#{namespace}.Question"
      end

      def c_label
        "#{namespace}.Label"
      end

      def c_answer
        "#{namespace}.Answer"
      end

      def toplevel_var(v)
        "#{namespace}.#{v.upcase}"
      end

      def ref(node)
        @refs[node] ||= gen_ref(node)
      end

      def gen_ref(node)
        if node.respond_to?(:ref) && node.ref
          node.ref
        else
          @serial += 1
          "_v#{@serial}"
        end
      end

      def newline
        @buffer << "\n"
      end

      def generate_runtime
        template_file = File.expand_path('../ember/runtime.coffee.erb', __FILE__)
        template = File.read(template_file)

        namespace = @namespace

        @runtime = ERB.new(template).result(binding)
      end
    end
  end
end

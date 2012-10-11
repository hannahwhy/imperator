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
        @serials = {}
      end

      def write
        puts @buffer
      end

      def logue
        @buffer << %Q{
          |#{v_surveys} = []
        }.margin

        newline

        yield
      end

      def survey(s)
        @buffer << %Q{
          |#{ident(s)} = #{c_survey}.create(name: "#{s.name}", uuid: "#{s.uuid}")
          |#{v_surveys}.push #{ident(s)}
        }.margin

        newline

        yield
      end

      def section(se, s)
        @buffer << %Q{
          |#{ident(se)} = #{c_section}.create(name: "#{se.name}", uuid: "#{se.uuid}")
          |#{ident(s)}.sections.push #{ident(se)}
        }.margin

        newline

        yield
      end

      def grid(q, se)
      end

      def group(q, se)
      end

      def question(q, se)
        @buffer << %Q{
          |#{ident(q)} = #{c_question}.create(tag: "#{q.tag}", text: "#{q.text}", uuid: "#{q.uuid}")
          |#{ident(se)}.questions.push #{ident(q)}
        }.margin

        newline

        q.answers.each { |a| answer(a, q) }
      end

      def repeater(q, se)
      end

      def answer(a, q)
        @buffer << %Q{
          |#{ident(q)}.answers.push #{c_answer}.create(tag: "#{a.tag}", text: "#{a.text}", uuid: "#{a.uuid}")
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

      def c_answer
        "#{namespace}.Answer"
      end

      def toplevel_var(v)
        "#{namespace}.#{v.upcase}"
      end

      def ident(node)
        @serials[node] ||= begin
                             @serial += 1
                             "_v#{@serial}"
                           end
      end

      def newline
        @buffer << "\n"
      end
    end
  end
end

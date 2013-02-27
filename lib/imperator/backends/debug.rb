module Imperator
  module Backends
    class Debug
      attr_accessor :compiler
      attr_reader :buffer

      def initialize
        @buffer = ""
      end

      def write
        puts @buffer
      end

      def logue
        @buffer << "PROLOGUE\n"
        yield
        @buffer << "EPILOGUE\n"
      end

      def survey(s)
        @buffer << "SURVEY START #{s.name} (#{s.uuid})\n"
        yield
        @buffer << "SURVEY END #{s.name}\n"
      end

      def section(se, s)
        n = "#{s.name} - #{se.name} (#{se.uuid}) (parent: #{se.parent.uuid})".upcase

        @buffer << n + "\n"
        @buffer << "-" * n.length
        @buffer << "\n\n"
        yield
        @buffer << "END #{n}\n"
        @buffer << "-" * (n.length + 4)
        @buffer << "\n\n"
      end

      def grid(q, se)
        @buffer << "GRID START (#{q.uuid}) (parent: #{q.parent.uuid})\n"

        maxlen = q.questions.max_by { |cq| cq.text.length }.text.length

        @buffer << ' ' * (maxlen + 8) + q.answers.map(&:text).join('    ')
        @buffer << "\n"

        q.questions.each { |cq| compiler.compile_question(cq, se) }

        @buffer << "GRID END\n"
      end

      def group(q, se)
        @buffer << "GROUP START #{q.name} (#{q.uuid}) (parent: #{q.parent.uuid})\n"

        q.questions.each { |cq| compiler.compile_question(cq, se) }

        @buffer << "GROUP END #{q.name}\n"
      end

      def label(q, se)
        @buffer << q.text + "\n"
      end

      def question(q, se)
        ident = q.tag.to_s

        @buffer << "Q#{ident}: " + q.text + " (#{q.uuid}) (parent: #{q.parent.uuid})\n"

        q.dependencies.each do |dep|
          @buffer << "Q#{ident} DEP: #{dep.rule}\n"
          dep.conditions.each do |cond|
            @buffer << "DEP #{dep.rule}: COND #{cond.tag} #{cond.parsed_condition}\n"
          end
        end

        q.answers.each { |a| answer(a, q) }
      end

      def repeater(q, se)
        @buffer << "REPEATER START #{q.text}\n"

        q.questions.each { |cq| compiler.compile_question(cq, se) }

        @buffer << "REPEATER END #{q.text}\n"
      end

      def answer(a, q)
        @buffer << '  [ ] (' + a.tag.to_s + ') ' + a.text.to_s + " (#{a.uuid})\n"
      end
    end
  end
end

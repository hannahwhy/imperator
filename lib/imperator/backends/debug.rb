module Imperator
  module Backends
    class Debug
      attr_accessor :compiler
      attr_reader :buffer

      def initialize
        @buffer = ""
      end

      def logue
        @buffer << "Prologue\n"
        yield
        @buffer << "Epilogue\n"
      end

      def survey(s)
        yield
        @buffer << "End survey #{s.name}\n"
      end

      def section(se, s)
        n = "#{s.name} - #{se.name}".upcase

        @buffer << n + "\n"
        @buffer << "-" * n.length
        @buffer << "\n\n"
        yield
        @buffer << "END #{n}\n"
        @buffer << "-" * (n.length + 4)
        @buffer << "\n\n"
      end

      def grid(q, se)
        @buffer << "GRID START\n"

        maxlen = q.questions.max_by { |cq| cq.text.length }.text.length
        
        @buffer << ' ' * (maxlen + 8) + q.answers.map(&:text).join('    ')
        @buffer << "\n"
        
        q.questions.each { |cq| compiler.compile_question(cq, se) }

        @buffer << "GRID END\n"
      end

      def group(q, se)
        @buffer << "GROUP START #{q.name}\n"

        q.questions.each { |cq| compiler.compile_question(cq, se) }

        @buffer << "GROUP END #{q.name}\n"
      end

      def label(q, se)
        @buffer << q.text + "\n"
      end

      def question(q, se)
        @buffer << 'Q' + q.tag.to_s + ': ' + q.text + "\n"
        
        q.answers.each { |a| answer(a, q) }
      end

      def repeater(q, se)
        @buffer << "REPEATER START #{q.text}\n"
        
        q.questions.each { |cq| compiler.compile_question(cq, se) }

        @buffer << "REPEATER END #{q.text}\n"
      end

      def answer(a, q)
        @buffer << '  [ ] ' + a.text.to_s + "\n"
      end
    end
  end
end

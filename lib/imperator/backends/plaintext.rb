require 'imperator/ast'

module Imperator
  module Backends
    class Plaintext
      include Imperator::Ast

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

      def question(q, se)
        case q
        when Label then
          @buffer << q.text + "\n"
          @buffer << "-" * q.text.length
          @buffer << "\n"
          yield
        when Group then
          @buffer << 'START GROUP ' << q.name.to_s << "\n"
          yield
          @buffer << 'END GROUP ' << q.name.to_s << "\n"
        when Grid then
          @buffer << 'START GRID ' << "\n"
          @buffer << q.text << "\n"
          yield
          @buffer << 'END GRID ' << "\n"
        when Question then
          @buffer << 'Q' + q.tag.to_s + ': ' + q.text + "\n" if q.respond_to?(:text)
          yield
        end
      end

      def answer(a, q)
        @buffer << '  [ ] ' + a.text.to_s + "\n"
      end
    end
  end
end

module Imperator
  module Backends
    class Debug
      attr_reader :buffer

      def initialize
        @buffer = ""
      end

      def write
        puts buffer
      end

      def prologue
        buffer << "PROLOGUE\n"
      end

      def answer(n, level, parent)
        if @in_grid
          @abuf << n
          yield
        else
          im "ANS #{n.tag || '(none)'}: #{n.text} (#{n.uuid}, type: #{n.type})\n", level
          yield
        end
      end

      def condition(n, level, parent)
        im "COND #{n.tag}: #{n.parsed_condition.inspect}\n", level
        yield
      end

      def dependency(n, level, parent)
        im "DEP #{n.parsed_rule.inspect}\n", level
        yield
      end

      def grid(n, level, parent)
        im "GRID #{n.uuid} START\n", level
        @in_grid = true
        @qbuf = []
        @abuf = []
        yield
        ms = @qbuf.map(&:text).map(&:length).max
        im (" " * ms) + @abuf.map(&:text).join("  ") + "\n", level
        @qbuf.each { |q| im("#{q.text}\n", level) }
        @in_grid = false
        im "GRID #{n.uuid} END\n", level
      end

      def group(n, level, parent)
        im "GROUP #{n.uuid} START\n", level
        im "#{n.name}\n", level
        yield
        im "GROUP #{n.uuid} END\n", level
      end

      def label(n, level, parent)
        im "LABEL #{n.text} (#{n.uuid})\n", level
        yield
      end

      def question(n, level, parent)
        if @in_grid
          @qbuf << n
          yield
        else
          im "QUESTION #{n.uuid} START\n", level
          im "#{n.text}\n", level
          yield
          im "QUESTION #{n.uuid} END\n", level
        end
      end

      def repeater(n, level, parent)
        im "REPEATER #{n.uuid} START\n", level
        yield
        im "REPEATER #{n.uuid} END\n", level
      end

      def section(n, level, parent)
        im "SECTION #{n.name} #{n.uuid} START\n", level
        yield
        im "SECTION #{n.name} #{n.uuid} END\n", level
      end

      def survey(n, level, parent)
        im "SURVEY START\n", level
        yield
        im "SURVEY END\n", level
      end

      def validation(n, level, parent)
        im "VDN #{n.uuid}\n", level
        im n.parsed_rule.inspect + "\n", level
        yield
      end

      def epilogue
        buffer << "EPILOGUE\n"
      end

      def im(msg, level)
        buffer << ("  " * level) << msg
      end
    end
  end
end

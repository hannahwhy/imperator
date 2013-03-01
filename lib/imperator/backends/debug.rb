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
          im n, "ANS #{n.tag || '(none)'}: #{n.text} (#{n.uuid}, type: #{n.type})\n", level
          yield
        end
      end

      def condition(n, level, parent)
        im n, "COND #{n.tag}: #{n.parsed_condition.inspect}\n", level
        yield
      end

      def dependency(n, level, parent)
        im n, "DEP #{n.parsed_rule.inspect}\n", level
        yield
      end

      def grid(n, level, parent)
        im n, "GRID #{n.uuid} START\n", level
        @in_grid = true
        @qbuf = []
        @abuf = []
        yield
        ms = @qbuf.map(&:text).map(&:length).max
        im n, (" " * ms) + @abuf.map(&:text).join("  ") + "\n", level
        @qbuf.each { |q| im(q, "#{q.text}\n", level) }
        @in_grid = false
        im n, "GRID #{n.uuid} END\n", level
      end

      def group(n, level, parent)
        im n, "GROUP #{n.uuid} START\n", level
        im n, "#{n.name}\n", level
        yield
        im n, "GROUP #{n.uuid} END\n", level
      end

      def label(n, level, parent)
        im n, "LABEL #{n.text} (#{n.uuid})\n", level
        yield
      end

      def question(n, level, parent)
        if @in_grid
          @qbuf << n
          yield
        else
          im n, "QUESTION #{n.uuid} #{n.tag} START\n", level
          im n, "#{n.text}\n", level
          yield
          im n, "QUESTION #{n.uuid} #{n.tag} END\n", level
        end
      end

      def repeater(n, level, parent)
        im n, "REPEATER #{n.uuid} START\n", level
        yield
        im n, "REPEATER #{n.uuid} END\n", level
      end

      def section(n, level, parent)
        im n, "SECTION #{n.name} #{n.uuid} START\n", level
        yield
        im n, "SECTION #{n.name} #{n.uuid} END\n", level
      end

      def survey(n, level, parent)
        im n, "SURVEY START\n", level
        yield
        im n, "SURVEY END\n", level
      end

      def validation(n, level, parent)
        im n, "VDN #{n.uuid}\n", level
        im n, n.parsed_rule.inspect + "\n", level
        yield
      end

      def epilogue
        buffer << "EPILOGUE\n"
      end

      def im(n, msg, level)
        buffer << sprintf("%05d", n.line) << " " << ("  " * level) << msg
      end
    end
  end
end

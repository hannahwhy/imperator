module Imperator
  module Ast
    class Survey < Struct.new(:name, :sections)
      def initialize(*args)
        super

        self.sections ||= []
      end
    end

    class Section < Struct.new(:name, :questions)
      def initialize(*args)
        super

        self.questions ||= []
      end
    end

    class Label < Struct.new(:text, :dependencies)
      attr_accessor :prev

      def initialize(*args)
        super

        self.dependencies ||= []
      end
    end

    class Question < Struct.new(:text, :tag, :options, :answers, :dependencies)
      attr_accessor :prev

      def initialize(*args)
        super

        self.answers ||= []
        self.dependencies ||= []
      end
    end

    class Answer < Struct.new(:text, :type, :tag, :validations)
      attr_accessor :prev

      def initialize(*args)
        super

        self.validations ||= []
      end
    end

    class Dependency < Struct.new(:rule, :conditions)
      def initialize(*args)
        super

        self.conditions ||= []
      end
    end

    class Validation < Struct.new(:rule)
    end
    
    class Group < Struct.new(:name, :display_type, :questions)
      attr_accessor :prev

      def initialize(*args)
        self.questions ||= []
      end
    end

    class Condition < Struct.new(:label, :predicate)
    end

    class Grid < Struct.new(:text, :questions, :answers)
      attr_accessor :prev

      def initialize(*args)
        super

        self.answers ||= []
        self.questions ||= []
      end
    end

    class Repeater < Struct.new(:text, :questions, :dependencies)
      attr_accessor :prev

      def initialize(*args)
        super

        self.questions ||= []
        self.dependencies ||= []
      end
    end
  end
end


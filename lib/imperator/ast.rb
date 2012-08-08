module Imperator
  module Ast
    class Survey < Struct.new(:name, :sections)
      def initialize(*args)
        super

        self.sections ||= []
      end
    end

    class Section < Struct.new(:name, :options, :questions)
      def initialize(*args)
        super

        self.questions ||= []
      end
    end

    class Label < Struct.new(:text, :tag, :options, :dependencies)
      def initialize(*args)
        super

        self.dependencies ||= []
      end
    end

    class Question < Struct.new(:text, :tag, :options, :answers, :dependencies)
      def initialize(*args)
        super

        self.answers ||= []
        self.dependencies ||= []
      end
    end

    class Answer < Struct.new(:text, :type, :tag, :validations)
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

    class Validation < Struct.new(:rule, :conditions)
      def initialize(*args)
        super

        self.conditions ||= []
      end
    end
    
    class Group < Struct.new(:name, :options, :questions, :dependencies)
      def initialize(*args)
        super

        self.questions ||= []
        self.dependencies ||= []
      end
    end

    class Condition < Struct.new(:label, :predicate)
    end

    class Grid < Struct.new(:text, :questions, :answers)
      def initialize(*args)
        super

        self.answers ||= []
        self.questions ||= []
      end
    end

    class Repeater < Struct.new(:text, :questions, :dependencies)
      def initialize(*args)
        super

        self.questions ||= []
        self.dependencies ||= []
      end
    end
  end
end


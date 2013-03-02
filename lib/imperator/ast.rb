require 'imperator/condition_parsing'
require 'imperator/rule_parsing'
require 'uuidtools'

module Imperator
  module Ast
    IMPERATOR_V0_NAMESPACE = UUIDTools::UUID.parse('824f34c2-e19f-11e1-82ec-c82a14fffebb')

    module Identifiable
      def identity
        @identity ||= ident(self)
      end

      def ident(o)
        case o
        when NilClass, TrueClass, FalseClass, Numeric, Symbol, String then o.to_s
        when Hash then o.keys.sort.map { |k| ident([k, o[k]]) }.flatten.join
        when Array then o.map { |v| ident(v) }.flatten.join
        when Struct then o.values.map { |v| ident(v) }.flatten.join
        else raise "Cannot derive identity of #{o.class}"
        end
      end

      def uuid
        UUIDTools::UUID.sha1_create(IMPERATOR_V0_NAMESPACE, identity)
      end
    end

    class Survey < Struct.new(:line, :name, :options, :sections, :translations)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.sections ||= []
        self.translations ||= []
      end

      def children
        translations + sections
      end
    end

    class Translation < Struct.new(:line, :lang, :path)
      include Identifiable

      attr_accessor :parent

      def children
        []
      end
    end

    class Section < Struct.new(:line, :tag, :name, :options, :questions)
      include Identifiable

      attr_accessor :parent

      alias_method :survey, :parent

      def initialize(*)
        super

        self.questions ||= []
      end

      def children
        questions
      end
    end

    class Label < Struct.new(:line, :text, :tag, :options, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.dependencies ||= []
      end

      def children
        dependencies
      end
    end

    class Question < Struct.new(:line, :text, :tag, :options, :answers, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.answers ||= []
        self.dependencies ||= []
      end

      def children
        answers + dependencies
      end
    end

    class Answer < Struct.new(:line, :t1, :t2, :tag, :validations)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.validations ||= []
      end

      def text
        t1.is_a?(String) ? t1 : ''
      end

      def type
        t2 || (t1 if t1.is_a?(Symbol))
      end

      def children
        validations
      end
    end

    class Dependency < Struct.new(:line, :rule, :conditions)
      include Identifiable
      include RuleParsing

      attr_accessor :parent

      def initialize(*)
        super

        self.conditions ||= []
      end

      def children
        conditions
      end
    end

    class Validation < Struct.new(:line, :rule, :conditions)
      include Identifiable
      include RuleParsing

      attr_accessor :parent

      def initialize(*)
        super

        self.conditions ||= []
      end

      def children
        conditions
      end
    end

    class Group < Struct.new(:line, :tag, :name, :options, :questions, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.questions ||= []
        self.dependencies ||= []
      end

      def children
        questions + dependencies
      end
    end

    class Condition < Struct.new(:line, :tag, :predicate)
      include Identifiable
      include ConditionParsing

      attr_accessor :parent

      def children
        []
      end
    end

    class Grid < Struct.new(:line, :text, :questions, :answers)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.answers ||= []
        self.questions ||= []
      end

      def children
        questions + answers
      end
    end

    class Repeater < Struct.new(:line, :text, :questions, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.questions ||= []
        self.dependencies ||= []
      end

      def children
        questions + dependencies
      end
    end
  end
end

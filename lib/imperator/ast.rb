require 'uuidtools'
require File.expand_path('../predicate/parser', __FILE__)

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

    class Survey < Struct.new(:name, :sections)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.sections ||= []
      end
    end

    class Section < Struct.new(:name, :options, :questions)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.questions ||= []
      end
    end

    class Label < Struct.new(:text, :tag, :options, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.dependencies ||= []
      end

      def ref
        "q#{tag}" if tag
      end
    end

    class Question < Struct.new(:text, :tag, :options, :answers, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.answers ||= []
        self.dependencies ||= []
      end

      def ref
        "q#{tag}" if tag
      end
    end

    class Answer < Struct.new(:text, :type, :tag, :validations)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.validations ||= []
      end

      def ref
        "a#{tag}" if tag
      end
    end

    class Dependency < Struct.new(:rule, :conditions)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.conditions ||= []
      end
    end

    class Validation < Struct.new(:rule, :conditions)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.conditions ||= []
      end
    end
    
    class Group < Struct.new(:name, :options, :questions, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.questions ||= []
        self.dependencies ||= []
      end
    end

    class Condition < Struct.new(:label, :raw_predicate, :predicate)
      include Identifiable

      attr_accessor :parent

      def parse_predicate
        self.predicate = Predicate::Parser.parse(raw_predicate)
      end
    end

    class Grid < Struct.new(:text, :questions, :answers)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.answers ||= []
        self.questions ||= []
      end
    end

    class Repeater < Struct.new(:text, :questions, :dependencies)
      include Identifiable

      attr_accessor :parent

      def initialize(*)
        super

        self.questions ||= []
        self.dependencies ||= []
      end
    end
  end
end


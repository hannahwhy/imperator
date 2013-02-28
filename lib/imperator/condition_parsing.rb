module Imperator
  # Surveyor conditions are an odd language consisting of a mix of Ruby and
  # custom operators represented as strings.  The language's only documentation
  # is its implementation.
  #
  # This module is a katana built from a sledgehammer.  It's intended to be
  # mixed into Condition AST nodes.
  #
  # Synopsis
  # --------
  #
  #     cond.parse
  #     cond.parsed_condition => #<Selected question=:q_2, answer=:a_1>
  #
  #
  # The Surveyor condition language
  # -------------------------------
  #
  # We find the following forms in Surveyor's kitchen sink survey:
  # 
  # 1. :q_2, "==", :a_1
  # 2. :q_2, "count>2"
  # 3. :q_montypython3, "==", {:string_value => "It is 'Arthur', King of the Britons", :answer_reference => "1"}
  # 4. :q_cooling_1, "!=", :a_4
  # 5. ">=", :integer_value => 0
  # 6. "=~", :regexp => "[0-9a-zA-z\. #]"
  #
  # These forms have the following (informal) meanings in English:
  #
  # 1. Answer 1 for question 2 is selected.
  # 2. Question 2 has more than two answers selected.
  # 3. Answer 1 for question montypython3 has string value "It is 'Arthur', King of the Britons".
  # 4. Answer a_4 for question cooling_1 is not selected.
  # 5. The single answer for the condition's question has an integer value greater than or equal to zero.
  # 6. The single answer for the condition's question has a regexp matching [0-9a-zA-z\. #].
  #
  # These forms correspond to the following condition nodes:
  #
  # 1. AnswerSelection
  # 2. AnswerCount
  # 3. AnswerSatisfies
  # 4. AnswerSelection
  # 5. SelfAnswerSatisfies 
  # 6. SelfAnswerSatisfies
  module ConditionParsing
    OP_REGEXP = />|>=|<|<=|==|=~|!=/

    module Normalization
      def qref_as_tag(qref)
        qref =~ /q_(.*)/ ? $1 : qref
      end

      def aref_as_tag(aref)
        aref =~ /a_(.*)/ ? $1 : aref
      end
    end

    module Tests
      def qref?(v)
        v.is_a?(Symbol)
      end

      def op?(v)
        v =~ OP_REGEXP
      end
      
      def aref?(v)
        v.is_a?(Symbol)
      end

      def criterion(v)
        if v.is_a?(Hash) && (k = v.keys.detect { |k| k =~ /(?:_value|regexp)\Z/ })
          [k, v[k]]
        end
      end

      def criterion?(v)
        !criterion(v).nil?
      end
    end

    class AnswerSelected < Struct.new(:qtag, :op, :atag)
      extend Normalization
      extend Tests

      def self.applies?(pred)
        qref?(pred[0]) &&
          (pred[1] == '==' || pred[1] == '!=') &&
          aref?(pred[2])
      end

      def self.build(pred, condition)
        qtag = qref_as_tag(pred[0])
        op = pred[1]
        atag = aref_as_tag(pred[2])

        new(qtag, op, atag)
      end
    end

    class AnswerCount < Struct.new(:qtag, :op, :value)
      extend Normalization
      extend Tests

      COUNT = /count(#{OP_REGEXP})(\d+)/

      def self.applies?(pred)
        qref?(pred[0]) && pred[1] =~ COUNT
      end

      def self.build(pred, condition)
        qtag = qref_as_tag(pred[0])
        pred[1] =~ COUNT

        new(qtag, $1, $2.to_i)
      end
    end

    class AnswerSatisfies < Struct.new(:qtag, :op, :atag, :criterion, :value)
      extend Normalization
      extend Tests

      def self.applies?(pred)
        qref?(pred[0]) && op?(pred[1]) && criterion?(pred[2])
      end

      def self.build(pred, condition)
        qtag = qref_as_tag(pred[0])
        op = pred[1]
        atag = aref_as_tag(pred[2][:answer_reference] || condition.parent.answers.first.tag)
        cri, value = criterion(pred[2])
        
        new(qtag, op, atag, cri, value)
      end
    end

    class SelfAnswerSatisfies < Struct.new(:op, :criterion, :value)
      extend Tests

      def self.applies?(pred)
        op?(pred[0]) && criterion?(pred[1])
      end

      def self.build(pred, condition)
        op = pred[0]
        cri, value = criterion(pred[1])

        new(op, cri, value)
      end
    end

    NODES = [
      AnswerSelected,
      AnswerCount,
      AnswerSatisfies,
      SelfAnswerSatisfies
    ]

    attr_reader :parsed_condition

    def parse_condition
      # Find out which nodes apply; only one should.  If we get multiple
      # matches, it's a fatal error.
      ns = applicable(predicate)
      raise "Ambiguous predicate: #{predicate}" if ns.length > 1
      raise "Unparseable predicate: #{predicate}" if ns.length < 1
     
      # Parse it.
      @parsed_condition = ns.first.build(predicate, self)
    end

    def applicable(predicate)
      NODES.select { |n| n.applies?(predicate) }
    end
  end
end

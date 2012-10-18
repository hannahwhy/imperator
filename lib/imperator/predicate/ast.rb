module Imperator
  module Predicate
    module Ast
      class BinaryOp < Struct.new(:lhs, :rhs)
      end

      comparators = %w(< <= == != >= > =~).zip(%w(Lt Le Eq Ne Ge Gt Ma))

      comparators.each do |symbol, name|
        class_eval <<-END
          class #{name} < BinaryOp
          end
        END
      end
      
      class StringValue < Struct.new(:value, :a_tag)
      end

      class IntegerValue < Struct.new(:value, :a_tag)
      end

      class RegexpValue < Struct.new(:value, :a_tag)
      end

      class Question < Struct.new(:q_tag)
      end

      class Answer < Struct.new(:a_tag)
      end

      class AnswerCount < Struct.new(:q_tag)
      end
    end
  end
end

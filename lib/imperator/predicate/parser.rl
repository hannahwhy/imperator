%%{
  machine parser;

  # A mixin for Condition nodes for generating uniform representations of
  # predicates.
  #
  # Some examples of predicates from the kitchen sink survey:
  #
  # 1. :q_2, "==", :a_1
  # 2. :q_2, "count>2"
  # 3. :q_montypython3, "==", {:string_value => "It is 'Arthur', King of the Britons", :answer_reference => "1"}
  # 4. :q_cooling_1, "!=", :a_4
  # 5. ">=", :integer_value => 0
  # 6. "=~", :regexp => "[0-9a-zA-z\. #]"
  #
  # Examples 1-4 all involve two questions: the question applied to the
  # condition and an auxillary question whose response is tested against the
  # predicate.  Examples 5-6 use only the question for the condition.
  alphtype char;

  action buffer { buffer << fc }

  action save_q_tag {
    parser.q_tag = buffer.dup
    buffer.clear
  }

  action save_a_tag {
    parser.a_tag = buffer.dup
    buffer.clear
  }

  action save_string {
    parser.value = buffer.dup
    buffer.clear
  }

  action save_integer {
    parser.value = buffer.to_i
    buffer.clear
  }

  action enter_criterion { fcall criterion; }

  action push_lt { parser.op = Lt.new }
  action push_le { parser.op = Le.new }
  action push_eq { parser.op = Eq.new }
  action push_ne { parser.op = Ne.new }
  action push_ge { parser.op = Ge.new }
  action push_gt { parser.op = Gt.new }
  action push_ma { parser.op = Ma.new }

  q_tag     = 'q_' (alnum | '_')+ @buffer %save_q_tag;
  a_tag     = 'a_' (alnum | '_')+ @buffer %save_a_tag;
  arrow     = '=>';
  operator  = '<'  %push_lt |
              '<=' %push_le |
              '==' %push_eq |
              '!=' %push_ne |
              '>=' %push_ge |
              '>'  %push_gt |
              '=~' %push_ma;

  string          = '"' ((any -- '"') | '\\"')* @buffer '"' %save_string;
  integer         = digit+ @buffer %save_integer;
  start_criterion = '{' @enter_criterion;
  end_criterion   = '}';

  criterion := |*
    ':string_value' arrow string => {
        parser.rhs = StringValue.new(parser.value)
    };

    ':integer_value' arrow integer => {
        parser.rhs = IntegerValue.new(parser.value)
    };

    ':regexp' arrow string => {
        parser.rhs = RegexpValue.new(parser.value)
    };

    ':answer_reference' arrow (string | integer) => {
        parser.a_tag = parser.value
    };

    ',' space* => { };
    end_criterion => { fret; };
  *|;

  # Q answered with A
  qa = q_tag space operator space a_tag %{
    parser.lhs = Question.new(parser.q_tag)
    parser.rhs = Answer.new(parser.a_tag)
  };

  # Q has at least this many answers
  qn = q_tag space 'count' space* operator space* integer %{
    parser.lhs = AnswerCount.new(parser.q_tag)
    parser.rhs = IntegerValue.new(parser.value)
  };

  # One or more of Q's answers satisfies these criteria
  qc = q_tag space operator space start_criterion %{
    parser.lhs = Question.new(parser.q_tag)
    parser.rhs.a_tag = parser.a_tag
  };

  # The answer for this condition's question satisfies it
  self = operator space start_criterion %{
    parser.lhs = Question.new(:self)
    parser.rhs.a_tag = parser.a_tag
  };

  main := qa | qn | qc | self;
}%%

require File.expand_path('../ast', __FILE__)

module Imperator
  module Predicate
    class Parser
      include Ast

      attr_accessor :a_tag
      attr_accessor :q_tag
      attr_accessor :value
      attr_accessor :op
      attr_accessor :lhs
      attr_accessor :rhs

      def self.parse(predicate)
        parser = Parser.new
        data = predicate.join(' ')
        buffer = ''
        eof = data.length
        stack = []

        %% write init;
        %% write exec;

        parser.op.lhs = parser.lhs
        parser.op.rhs = parser.rhs
        parser.op
      end

      %% write data;
    end
  end
end

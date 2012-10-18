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
  action save_qref { puts "q: #{buffer}"; buffer.clear }
  action save_aref { puts "a: #{buffer}"; buffer.clear }
  action save_string { puts "string: #{buffer}"; buffer.clear }
  action enter_criterion { puts 'jump to criterion scanner'; fcall criterion; }

  action push_lt { puts "lt" }
  action push_le { puts "le" }
  action push_eq { puts "eq" }
  action push_ne { puts "ne" }
  action push_ge { puts "ge" }
  action push_gt { puts "gt" }
  action push_ma { puts "ma" }

  q_ref     = 'q_' alnum+ @buffer %save_qref;
  a_ref     = 'a_' alnum+ @buffer %save_aref;
  arrow     = '=>';
  operator  = '<'  %push_lt |
              '<=' %push_le |
              '==' %push_eq |
              '!=' %push_ne |
              '>=' %push_ge |
              '>'  %push_gt |
              '=~' %push_ma;

  string          = '"' ((any -- '"') | '\\"')* @buffer '"' %save_string;
  start_criterion = '{' @enter_criterion;
  end_criterion   = '}';

  criterion := |*
    ':string_value' arrow string => { puts 'string value' };
    ':integer_value' arrow digit+ => { puts 'integer value' };
    ':regexp' arrow string => { puts 'regexp' };
    ':answer_reference' arrow (string | digit+) => { puts 'answer reference' };
    ',' space* => { };
    end_criterion => { fret; };
  *|;

  # Q answered with A
  qa = q_ref space operator space a_ref;

  # Q has at least this many answers
  qn = q_ref space 'count' space* operator space* digit+;

  # One or more of Q's answers satisfies these criteria
  qc = q_ref space operator space start_criterion;

  # The answer for this condition's question satisfies it
  self = operator space start_criterion;

  main := qa | qn | qc | self;
}%%

module Imperator
  module Predicate
    class Parser
      def self.parse(predicate)
        new.tap do |parser|
          data = predicate.join(' ')
          buffer = ''
          eof = data.length
          stack = []

          %% write init;
          %% write exec;
        end
      end

      %% write data;
    end
  end
end

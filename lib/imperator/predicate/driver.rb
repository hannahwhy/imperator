require './parser'

inps = [
  [:q_2, "==", :a_1],
  [:q_2, "count>2"],
  [:q_montypython3, "==", {:string_value => "It is 'Arthur', King of the Britons", :answer_reference => "1"}],
  [:q_cooling_1, "!=", :a_4],
  [">=", :integer_value => 0],
  ["=~", :regexp => "[0-9a-zA-z\. #]"]
]

inps.each do |inp|
  puts inp.join(' ')

  Imperator::Predicate::Parser.parse(inp)

  puts '-' * 78
end

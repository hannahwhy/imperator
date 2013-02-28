require 'imperator/rule_parser'

module Imperator
  # Rules are chains of condition tags joined by ANDs and ORs.
  # Parentheses may be used to modify precedence.
  #
  # Examples:
  #
  # A
  # A or B
  # A and (B or C)
  # A and (B or (C and D))
  #
  # Surveyor actually uses eval (!) to evaluate dependencies.  This means that
  # Surveyor's dependency language inherits its precedence rules from Ruby.
  module RuleParsing
    attr_reader :parsed_rule

    def parse_rule
      parser = RuleParser.new(rule)
      parser.parse
      @parsed_rule = parser.ast
    end
  end
end

require 'imperator/rule_parser'
require 'set'

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

    def referenced_conditions
      Set.new.tap do |cs|
        visit_rule { |n| cs << n.name if n.respond_to?(:name) }
      end
    end

    def visit_rule(rule = parsed_rule, &block)
      yield rule

      if rule.respond_to?(:conj)
        visit_rule(rule.left, &block)
        visit_rule(rule.right, &block)
      end
    end
  end
end

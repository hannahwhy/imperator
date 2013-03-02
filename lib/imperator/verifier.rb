require 'imperator/ast'
require 'imperator/visitation'

module Imperator
  class Verifier
    include Ast
    include Visitation

    attr_reader :atag_count
    attr_reader :atag_expectations
    attr_reader :by_qref
    attr_reader :ctag_count
    attr_reader :errors
    attr_reader :qtag_count
    attr_reader :qtag_expectations
    attr_reader :surveys

    def initialize(surveys)
      @atag_count = Hash.new(0)
      @atag_expectations = Hash.new(0)
      @by_qref = {}
      @ctag_count = Hash.new(0)
      @errors = []
      @qtag_count = Hash.new(0)
      @qtag_expectations = Hash.new(0)
      @surveys = surveys
    end

    def verify
      surveys.map { |s| verify_survey(s) }.all?
    end

    def verify_survey(s)
      visit(s, true) do |n, level, prev, boundary|
        case n
        when Condition; inspect_condition(n)
        when Dependency, Validation; inspect_conditional(n)
        when Question; inspect_question(n)
        end
      end

      run_checks

      errors.empty?
    end

    # When we see a question:
    #
    # 1. If the question has a non-empty tag, index the question by its tag.
    # 2. Register references to it and all of its answers.
    def inspect_question(q)
      index_question(q) unless q.tag.empty?
      ref_question(q)
      q.answers.each { |a| ref_answer(q, a) }
    end

    # There are three references in conditions that we have to worry about:
    # 
    # - the question ref, if one exists
    # - the answer ref, if one exists
    # - the condition tag
    #
    # Seeing a condition registers a reference to the condition and
    # expectations for the qref and aref if those refs exist.
    def inspect_condition(c)
      pc = c.parsed_condition

      ctag_count[[c.parent, c.tag]] += 1

      pending_question(pc.qtag, c) if pc.qtag
      pending_answer(pc.qtag, pc.atag, c) if pc.qtag && pc.atag
    end

    # When we see a dependency or validation, register references to all of its
    # conditions.
    def inspect_conditional(c)
      c.referenced_conditions.each do |tag|
        key = [c, tag]

        unless ctag_count.has_key?(key)
          ctag_count[key] = 0
        end
      end
    end

    # Find all unsatisfied expectations.
    def run_checks
      find_bad_refs
      find_duplicate_refs
    end
    
    def find_bad_refs
      bad_refs(qtag_count) do |qt|
        errors << Error.new(Question, :bad_ref, qt, qtag_expectations[qt])
      end

      bad_refs(atag_count) do |qt, at|
        errors << Error.new(Answer, :bad_ref, at, atag_expectations[[qt, at]])
      end

      bad_refs(ctag_count) do |c, tag|
        errors << Error.new(Condition, :bad_ref, tag, c)
      end
    end

    def bad_refs(refs)
      refs.each { |k, c| yield k if c < 1 }
    end

    def find_duplicate_refs
      by_qref.select { |k, v| v.length > 1 }.each do |k, vs|
        errors << Error.new(Question, :duplicate_qref, k, vs)
      end
    end

    def index_question(q)
      key = q.tag

      by_qref[key] = [] unless by_qref.has_key?(key)
      by_qref[key] << q
    end

    def ref_question(q)
      qtag_count[q.tag.to_s] += 1
    end

    def ref_answer(q, a)
      atag_count[[q.tag.to_s, a.tag.to_s]] += 1
    end

    def pending_question(qtag, from)
      qtag_expectations[qtag] = from

      unless qtag_count.has_key?(qtag)
        qtag_count[qtag] = 0
      end
    end

    def pending_answer(qtag, atag, from)
      key = [qtag, atag]
      atag_expectations[key] = from

      unless atag_count.has_key?(key)
        atag_count[key] = 0
      end
    end

    class Error < Struct.new(:node_type, :error_type, :key, :at_fault)
    end
  end
end

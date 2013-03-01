require 'imperator/ast'
require 'imperator/visitation'

module Imperator
  class Verifier
    include Ast
    include Visitation

    attr_reader :atag_count
    attr_reader :atag_expectations
    attr_reader :errors
    attr_reader :qtag_count
    attr_reader :qtag_expectations
    attr_reader :surveys

    def initialize(surveys)
      @atag_count = Hash.new(0)
      @atag_expectations = Hash.new(0)
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
        when Question; verify_question(n)
        when Condition; verify_condition(n)
        end
      end

      run_checks

      errors.empty?
    end

    # When we see a question, register references to it and all of its answers.
    def verify_question(q)
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
    def verify_condition(c)
      pc = c.parsed_condition

      pending_question(pc.qtag, c) if pc.qtag
      pending_answer(pc.qtag, pc.atag, c) if pc.qtag && pc.atag
    end

    # Find all unsatisfied expectations.
    def run_checks
      aerrs = atag_count.select { |_, c| c < 1 }.map { |k, _| k }
      qerrs = qtag_count.select { |_, c| c < 1 }.map { |qt, _| qt }

      qerrs.each do |qt|
        errors << Error.new(Question, qt, qtag_expectations[qt])
      end

      aerrs.each do |qt, at|
        errors << Error.new(Answer, at, atag_expectations[[qt, at]])
      end
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

    class Error < Struct.new(:node_type, :key, :expected_by)
    end
  end
end

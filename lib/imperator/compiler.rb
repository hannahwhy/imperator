require 'imperator/ast'

module Imperator
  class Compiler
    include Imperator::Ast

    attr_accessor :backend

    def initialize(surveys)
      @surveys = surveys
    end

    def compile
      backend.compiler = self

      backend.logue do
        @surveys.each { |s| compile_survey(s) }
      end
    end

    def compile_survey(s)
      backend.survey(s) do
        s.sections.each { |se| compile_section(se, s) }
      end
    end

    def compile_section(se, s)
      backend.section(se, s) do
        se.questions.each { |q| compile_question(q, se) }
      end
    end

    def compile_question(q, se)
      b = backend

      case q
      when Grid then b.grid(q, se)
      when Group then b.group(q, se)
      when Label then b.label(q, se)
      when Question then b.question(q, se)
      when Repeater then b.repeater(q, se)
      else raise "Unknown question type #{q.class}"
      end
    end
  end
end


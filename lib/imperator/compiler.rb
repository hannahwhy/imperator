module Imperator
  class Compiler
    attr_accessor :backend

    def initialize(surveys)
      @surveys = surveys
    end

    def compile
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
      backend.question(q, se) do
        if q.respond_to?(:questions)
          q.questions.each { |cq| compile_question(cq, q) }
        end

        if q.respond_to?(:answers)
          q.answers.each { |a| compile_answer(a, q) }
        end
      end
    end

    def compile_answer(a, q)
      backend.answer(a, q)
    end
  end
end


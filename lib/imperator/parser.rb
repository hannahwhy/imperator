require 'imperator/ast'

module Imperator
  class Parser < BasicObject
    attr_accessor :file
   
    attr_reader :surveys
    attr_reader :current_answer
    attr_reader :current_dependency
    attr_reader :current_grid
    attr_reader :current_group
    attr_reader :current_question
    attr_reader :current_repeater
    attr_reader :current_section
    attr_reader :current_survey
    attr_reader :current_validation

    def initialize(file)
      self.file = file

      @surveys = []
      @current_answer = nil
      @current_dependency = nil
      @current_grid = nil
      @current_group = nil
      @current_question = nil
      @current_repeater = nil
      @current_section = nil
      @current_survey = nil
      @current_validation = nil
    end

    def parse
      instance_eval(::File.read(file))
    end

    def survey(name, &block)
      @current_survey = Ast::Survey.new(name)
      @surveys << @current_survey

      _with_unwind do
        instance_eval(&block)
      end
    end

    def section(name, options = {}, &block)
      @current_section = Ast::Section.new(name)
      @current_section.options = options
      @current_survey.sections << @current_section

      _with_unwind do
        instance_eval(&block)
      end
    end

    def group(name, options = {}, &block)
      display_type = options[:display_type]

      group = Ast::Group.new(name, display_type)
      @current_section.questions << group
      group.prev = @current_question

      _with_unwind do
        @current_group = group
        @current_question = nil
        @current_answer = nil
        instance_eval(&block)
      end
    end

    def dependency(options = {})
      rule = options[:rule]
      dependency = Ast::Dependency.new(rule)
      @current_dependency = dependency

      # Is there a current question? If not, is there a group, grid, or repeater?
      if @current_question
        @current_question.dependencies << dependency
      elsif @current_group
        @current_group.dependencies << dependency
      elsif @current_grid
        @current_grid.dependencies << dependency
      elsif @current_repeater
        @current_repeater.dependencies << dependency
      else
        _wtf(dependency)
      end
    end

    def validation(options = {})
      rule = options[:rule]
      validation = Ast::Validation.new(rule)
      @current_validation = validation
      @current_answer.validations << validation
    end
    
    def grid(text, &block)
      grid = Ast::Grid.new(text)
      grid.prev = @current_question
      @current_section.questions << grid

      _with_unwind do
        @current_grid = grid
        @current_question = nil
        @current_answer = nil
        instance_eval(&block)
      end
    end

    def repeater(text, &block)
      repeater = Ast::Repeater.new(text)
      repeater.prev = @current_question
      @current_section.questions << repeater

      _with_unwind do
        @current_repeater = repeater
        @current_question = nil
        @current_answer = nil
        instance_eval(&block)
      end
    end

    def _with_unwind
      begin
        old_answer = @current_answer
        old_dependency = @current_dependency
        old_grid = @current_grid
        old_group = @current_group
        old_question = @current_question
        old_repeater = @current_repeater
        old_section = @current_section
        old_survey = @current_survey
        old_validation = @current_validation
        
        yield
      ensure
        @current_answer = old_answer
        @current_dependency = old_dependency
        @current_grid = old_grid
        @current_group = old_group
        @current_question = old_question
        @current_repeater = old_repeater
        @current_section = old_section
        @current_survey = old_survey
        @current_validation = old_validation
      end
    end

    def _label(tag, text, options = {})
      label = Ast::Label.new(text, tag)
      label.options = options
      label.prev = @current_question
      @current_section.questions << label
      @current_question = label
    end

    def _question(tag, text, options = {})
      question = Ast::Question.new(text, tag, options)
      question.prev = @current_question

      if @current_group
        @current_group.questions << question
      elsif @current_grid
        @current_grid.questions << question
      else
        @current_section.questions << question
      end

      @current_question = question
      @current_answer = nil
    end

    def _answer(tag, text, type = nil, options = {})
      answer = Ast::Answer.new(text, type, tag)
      answer.prev = @current_answer

      # In grids, there is no current question.
      if @current_question
        @current_question.answers << answer
      elsif @current_grid
        @current_grid.answers << answer
      else
        _wtf(answer)
      end

      @current_answer = answer
    end

    def _condition(label, *predicate)
      condition = Ast::Condition.new(label, predicate)
      @current_dependency.conditions << condition
    end

    # Bailout method.
    def _wtf(object)
      ::Kernel.raise "Don't know how to associate #{object.class}"
    end

    # I really wish Surveyor didn't do this. :(
    def method_missing(m, *args, &block)
      case m
      when /^q(?:uestion)?(?:_(.+))?$/
        _question(*args.unshift($1), &block)
      when /^a(?:nswer)?(?:_(.+))?$/
        _answer(*args.unshift($1), &block)
      when /^l(?:abel)?(?:_(.+))?$/
        _label(*args.unshift($1), &block)
      when /^condition(?:_(.+))$/
        _condition(*args.unshift($1), &block)
      else
        super
      end
    end
  end
end

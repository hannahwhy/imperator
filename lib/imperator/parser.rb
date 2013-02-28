require 'imperator/ast'

module Imperator
  class Parser < BasicObject
    attr_accessor :file
    attr_reader :surveys

    def initialize(file)
      self.file = file

      @surveys = []
    end

    def parse
      instance_eval(::File.read(file), file)
    end

    def survey(name, options = {}, &block)
      survey = Ast::Survey.new(name, options)
      @surveys << survey

      _with_unwind do
        @current_node = survey
        instance_eval(&block)
      end
    end

    def section(name, options = {}, &block)
      section = Ast::Section.new(name, options)
      section.parent = @current_node
      @current_node.sections << section

      _with_unwind do
        @current_node = section
        instance_eval(&block)
      end
    end

    def group(name = nil, options = {}, &block)
      group = Ast::Group.new(name, options)
      group.parent = @current_node
      @current_node.questions << group

      _with_unwind do
        @current_node = group
        instance_eval(&block)
      end
    end

    def dependency(options = {})
      rule = options[:rule]
      dependency = Ast::Dependency.new(rule)

      # Does this apply to a question?  If not, we'll apply it to the current
      # node.
      if @current_question
        dependency.parent = @current_question
        @current_question.dependencies << dependency
      else
        dependency.parent = @current_node
        @current_node.dependencies << dependency
      end

      dependency.parse_rule
      @current_dependency = dependency
    end

    def grid(text, &block)
      grid = Ast::Grid.new(text)
      grid.parent = @current_node
      @current_node.questions << grid

      _with_unwind do
        @current_question = grid
        @current_node = grid
        instance_eval(&block)
      end
    end

    def repeater(text, &block)
      repeater = Ast::Repeater.new(text)
      repeater.parent = @current_node
      @current_node.questions << repeater

      _with_unwind do
        @current_node = repeater
        instance_eval(&block)
      end
    end

    def validation(options = {})
      rule = options[:rule]
      validation = Ast::Validation.new(rule)
      validation.parent = @current_dependency
      validation.parse_rule
      @current_answer.validations << validation
      @current_dependency = validation
    end

    def _label(tag, text, options = {})
      question = Ast::Label.new(text, tag, options)
      question.parent = @current_node
      @current_node.questions << question
      @current_question = question
    end

    def _question(tag, text, options = {})
      question = Ast::Question.new(text, tag, options)
      question.parent = @current_node
      @current_node.questions << question
      @current_question = question
    end

    def _answer(tag, text, type = nil, options = {})
      answer = Ast::Answer.new(text, type, tag)
      answer.parent = @current_question
      @current_question.answers << answer
      @current_answer = answer
    end

    def _condition(label, *predicate)
      condition = Ast::Condition.new(label, predicate)
      condition.parent = @current_dependency
      condition.parse_condition
      @current_dependency.conditions << condition
    end

    def _with_unwind
      old_dependency = @current_dependency
      old_node = @current_node
      old_question = @current_question
      old_answer = @current_answer

      yield

      @current_dependency = old_dependency
      @current_node = old_node
      @current_question = old_question
      @current_answer = old_answer
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

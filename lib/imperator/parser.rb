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
      survey = Ast::Survey.new(sline, name, options)
      @surveys << survey

      _with_unwind do
        @current_node = survey
        instance_eval(&block)
      end
    end

    def translations(spec)
      spec.each do |lang, path|
        translation = Ast::Translation.new(sline, lang, path)
        translation.parent = @current_node
        @current_node.translations << translation
      end
    end

    def dependency(options = {})
      rule = options[:rule]
      dependency = Ast::Dependency.new(sline, rule)

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

    def validation(options = {})
      rule = options[:rule]
      validation = Ast::Validation.new(sline, rule)
      validation.parent = @current_dependency
      validation.parse_rule
      @current_answer.validations << validation
      @current_dependency = validation
    end

    def _grid(tag, text, &block)
      grid = Ast::Grid.new(sline, tag.to_s, text)
      grid.parent = @current_node
      @current_node.questions << grid

      _with_unwind do
        @current_question = grid
        @current_node = grid
        instance_eval(&block)
      end
    end

    def _repeater(tag, text, &block)
      repeater = Ast::Repeater.new(sline, tag.to_s, text)
      repeater.parent = @current_node
      @current_node.questions << repeater

      _with_unwind do
        @current_node = repeater
        instance_eval(&block)
      end
    end

    def _label(tag, text, options = {})
      question = Ast::Label.new(sline, text, tag.to_s, options)
      question.parent = @current_node
      @current_node.questions << question
      @current_question = question
    end

    def _question(tag, text, options = {})
      question = Ast::Question.new(sline, text, tag.to_s, options)
      question.parent = @current_node
      @current_node.questions << question
      @current_question = question
    end

    def _answer(tag, t1, t2 = nil, options = {})
      answer = Ast::Answer.new(sline, t1, t2, tag.to_s)
      answer.parent = @current_question
      @current_question.answers << answer
      @current_answer = answer
    end

    def _condition(label, *predicate)
      condition = Ast::Condition.new(sline, label, predicate)
      condition.parent = @current_dependency
      condition.parse_condition
      @current_dependency.conditions << condition
    end

    def _group(tag, name = nil, options = {}, &block)
      group = Ast::Group.new(sline, tag.to_s, name, options)
      group.parent = @current_node
      @current_node.questions << group

      _with_unwind do
        @current_question = nil
        @current_node = group
        instance_eval(&block)
      end
    end

    def _section(tag, name, options = {}, &block)
      section = Ast::Section.new(sline, tag.to_s, name, options)
      section.parent = @current_node
      @current_node.sections << section

      _with_unwind do
        @current_node = section
        instance_eval(&block)
      end
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

    # Current line in the survey.
    def sline
      ::Kernel.caller(1).detect { |l| l.include?(file) }.split(':')[1]
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
      when /^g(?:roup)?(?:_(.+))?$/
        _group(*args.unshift($1), &block)
      when /^s(?:ection)?(?:_(.+))?$/
        _section(*args.unshift($1), &block)
      when /^grid(?:_(.+))?$/
        _grid(*args.unshift($1), &block)
      when /^repeater(?:_(.+))?$/
        _repeater(*args.unshift($1), &block)
      when /^dependency_.+$/
        dependency(*args)
      when /^condition(?:_(.+))$/
        _condition(*args.unshift($1), &block)
      else
        super
      end
    end
  end
end

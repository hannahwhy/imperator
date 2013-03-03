require 'imperator/visitation'

module Imperator
  class TextExtractor
    include Ast
    include Visitation

    attr_reader :surveys
    attr_reader :extractions

    def initialize(surveys)
      @extractions = {}
      @surveys = surveys
    end

    def extract
      surveys.each do |s|
        for_survey(s) do
          visit(s, true) do |n, _, _, _|
            case n
            when Survey; read_texts n, n.name
            when Section; read_texts n, n.name
            when Label; read_texts n, n.text
            when Question; read_texts n, n.text
            when Answer; read_texts n, n.text, n.options[:help_text]
            when Group; read_texts n, n.name
            when Grid; read_texts n, n.text
            when Repeater; read_texts n, n.text
            end
          end
        end
      end
    end

    private

    def read_texts(n, *texts)
      texts.each do |t|
        next if t.nil? || t.strip.empty?

        add_text(n, t)
      end
    end

    def for_survey(s)
      begin
        @current_survey = s
        extractions[@current_survey] = {}
        @current_db = extractions[@current_survey]
        yield
      ensure
        @current_db = nil
        @current_survey = nil
      end
    end

    def add_text(n, text)
      unless @current_db.has_key?(n)
        @current_db[n] = []
      end

      @current_db[n] << text
    end
  end
end

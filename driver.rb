$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'pp'
require 'imperator/parser'

file = File.expand_path('../kitchen_sink_survey.rb', __FILE__)


p = Imperator::Parser.new(file)
p.parse
pp p.current_survey

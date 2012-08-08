$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'pp'
require 'imperator/parser'
require 'imperator/compiler'
require 'imperator/backends/plaintext'

file = File.expand_path('../kitchen_sink_survey.rb', __FILE__)

p = Imperator::Parser.new(file)
p.parse

c = Imperator::Compiler.new(p.surveys)
b = Imperator::Backends::Plaintext.new

c.backend = b
c.compile

puts b.buffer

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'pp'
require 'imperator/parser'
require 'imperator/compiler'
require 'imperator/backends/debug'

file = ARGV[0]

p = Imperator::Parser.new(file)
p.parse

c = Imperator::Compiler.new(p.surveys)
b = Imperator::Backends::Debug.new

c.backend = b
c.compile

puts b.buffer

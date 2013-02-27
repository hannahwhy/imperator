$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'pp'
require 'imperator/parser'
require 'imperator/compiler'
require 'imperator/backends/debug'
require 'imperator/backends/ember'

backend = Imperator::Backends::Debug
rev = `git rev-parse HEAD`.chomp
puts "Imperator #{rev} - backend: #{backend}"

file = ARGV[0]

p = Imperator::Parser.new(file)
p.parse

c = Imperator::Compiler.new(p.surveys)
b = backend.new

c.backend = b
c.compile

b.write

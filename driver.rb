$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'pp'
require 'imperator/backends/debug'
require 'imperator/backends/webpage'
require 'imperator/compiler'
require 'imperator/parser'
require 'imperator/verifier'

backend = Imperator::Backends.const_get(ENV['BACKEND'] || 'Debug')
rev = `git rev-parse HEAD`.chomp
puts "Imperator #{rev} - backend: #{backend}"

file = File.expand_path("../#{ARGV[0]}", __FILE__)
data = File.read(file)

p = Imperator::Parser.new(data, file)
p.parse

v = Imperator::Verifier.new(p.surveys)
ok = v.verify

b = backend.new
c = Imperator::Compiler.new(p.surveys, b)

c.compile

b.write

puts '-' * 78

v.errors.each do |e|
  puts "#{file}:#{e.expected_by.line}: #{e.node_type} #{e.key} is not defined"
end

#!/usr/bin/env ruby

IRB.conf[:PROMPT_MODE] = :SIMPLE

begin
  require 'irbtools/configure'
  Irbtools.railsrc = false
  Irbtools.start
rescue LoadError
  if defined? Rails
    puts "Note: IRB Tools is not in Gemfile (gem 'irbtools', require: false)"
  else
    puts 'Note: IRB Tools is not installed (gem install irbtools)'
  end
end

def vim(object = TOPLEVEL_BINDING, method_name)
  file, line = object.method(method_name).source_location
  Kernel.system('vim', file, "+#{line}")
end

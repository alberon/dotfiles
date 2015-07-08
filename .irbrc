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

def vim(object, method_name = nil)
  # This is for Ruby 1.8 support:
  if method_name.nil?
    object, method_name = TOPLEVEL_BINDING, object
  end
  file, line = object.method(method_name).source_location
  Kernel.system('vim', file, "+#{line}")
end

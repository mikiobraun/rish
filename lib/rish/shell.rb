# Copyright (c) 2010 by Mikio L. Braun
# rish is distributed under a BSD-style license. See COPYING

require 'profiler'

require 'rish/hook'
require 'rish/irb'
require 'rish/interactive'

# The Rish main module.
#
# Call Rish.shell to start a shell.
module Rish
  module_function

  # Start a new Rish shell. Supported types are :irb and :rish.
  def shell(type=:irb)
    hook = Hook.new
    case type
    when :irb
      IRB.rish_start(nil, hook)
    when :rish
      i = Interactive.new
      i.hook = hook
      i.run
    end
  end
end

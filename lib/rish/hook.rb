# Copyright (c) 2010 by Mikio L. Braun
# rish is distributed under a BSD-style license. See COPYING

require 'profiler'
require 'rish/autoreload'
require 'rish/commands'

module Rish
  # The main Hook class.
  #
  # This adds the main functionality realized through before
  # and after hooks.
  #
  # If you want to add further capabilities, here is the place to do
  # so.
  class Hook
    @profile = false
    
    # Called with each input line.
    #
    # If a special command is recognized, the input line is changed
    # accordingly. For example, "!ls" becomes "%x{ls}"
    def before(line)
      Autoreload::reload_all
      if line[0] == ?!
        if line[1] == ?&
          line = line[2..-1] + "&"
        end
        if line[-1] == ?&
          "Thread.new { %x{#{line[1...-1]}} };"
        else
          "%x{#{line[1..-1]}}"
        end
      elsif line[0] == ?? and line.size > 2
        "Rish::Commands.help \"#{line[1..-1]}\""
      elsif line[0] == ?@
        if line[1] == ?p
          Profiler__::start_profile
          @profile = true
          line = line[2..-1]
        elsif line[1] == ?h
          'Rish::Commands.help'
        else
          line
        end
      else
        line
      end
    end

    # Called on the result of an evaluation.
    #
    # Used here mainly to clean up after the profiler.
    def after(result)
      if @profile
        Profiler__::stop_profile
        Profiler__::print_profile($stdout)
        @profile = false
      end
      result
    end
  end  
end

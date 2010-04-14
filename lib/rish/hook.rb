require 'profiler'
require 'rish/autoreload'
require 'rish/commands'

module Rish
  class Hook
    @profile = false
    
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
        else
          line
        end
      else
        line
      end
    end
    
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

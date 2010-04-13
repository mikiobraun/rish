require 'profiler'

require 'marge/shell/interactive'
require 'marge/shell/autoreload'

class String # :nodoc:
  def starts_with?(s)
    self[0..s.length] == s
  end
end

module Marge
  module Shell
    module_function

    def help(word)
      puts %x{qri #{word}}
    end

    class MargeShell < Interactive
      @profile = false

      def process_line(line)
        AutoReload::reload_all
        if line[0] == ?!
          if line[-1] == ?&
            "Thread.new { %x{#{line[1...-1]}} };"
          else
            "%x{#{line[1..-1]}}"
          end
        elsif line[0] == ?? and line.size > 2
          "Marge::Shell.help \"#{line[1..-1]}\""
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

      def process_result(result)
        if @profile
          Profiler__::stop_profile
          Profiler__::print_profile($stdout)
          @profile = false
        end
        result
      end
    end
  end
end

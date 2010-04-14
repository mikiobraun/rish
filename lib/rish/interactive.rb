# Copyright (c) 2010 by Mikio L. Braun
# rish is distributed under a BSD-style license. See COPYING

require 'readline'
require 'pp'

module Rish
  # Rish's own interactive mode.
  #
  # Similar to IRB, but much smaller. The advantage it has is that it
  # doesn't look for line continuations and works better with rish's
  # built-in commands (well, is this a feature or a bug?)
  #
  # Also, if the line ends in ";", the result is not plotted, just as in 
  # matlab.
  class Interactive
    # Start an interactive shell.
    def run
      read_history

      #binding = Workspace.new.binding
      binding = Object::TOPLEVEL_BINDING

      Readline.completion_proc = proc do |s|
        if /([a-zA-Z_]+)(::|\.)([^.]*)/ =~ s
          prefix = $1
          sep = $2
          s = $3
          
          candidates = get_candidates(binding, prefix + sep)
        else
          prefix = ''
          sep = ''

          candidates = get_candidates(binding)
        end

        candidates = candidates.select {|m| starts_with(m, s)}
        candidates.map! {|c| prefix + sep + c}
      end
      
      thread = Thread.current

      state = :input

      trap('SIGINT') do
        case state
        when :input
          puts "Exiting..."
          thread.raise Interrupt
          exit
        when :calc
          thread.raise Interrupt
        end
      end

      lineno = 0
      s = 'okay'
      while s
        lineno += 1
        state = :input
        s = Readline.readline("interactive:#{lineno}> ", true)
        #print "interactive:#{lineno}> "
        #s = gets.chomp
        break if (s.nil? or s == 'exit' or s == 'quit')
        begin
          s = @hook.before(s) if @hook
          state = :calc
          result = eval(s, binding, 'interactive', lineno)
          state = :input
          result = @hook.after(result) if @hook
          if s[-1] != ?;
            print_result(result)
            $ans = result
          end
        rescue SyntaxError => e
          puts "SyntaxError: #{e}"
        rescue StandardError, ScriptError => e
          puts "#{e.class}: #{e.to_s[0..1000]}"
          print_backtrace e.backtrace
        rescue SignalException => e
          puts "Caught #{e.class}"
          print_backtrace e.backtrace
        end
      end

      write_history
      exit
    end

    # Add a hook which is called before and after each line.
    #
    # The hook object as to have a +before+ and +after+ method.
    # The +before+ method is called with the input line
    # and has to return it or a changed version. Likewise,
    # the +after+ method gets the result of the evaluation and
    # has to return the value or a changed version.
    def hook=(h)
      @hook = h
    end

    #######
    private
    #######

    def history_file
      File.join(ENV['HOME'], '.marge_history')
    end

    def print_result(result)
      puts result.inspect unless result.nil?
    end

    def read_history
      begin
        open(history_file, 'r').each do |l|
          Readline::HISTORY << l.chomp
        end
      rescue Errno::ENOENT
        # do nothing
      end
    end

    def write_history
      open(history_file, 'w') do |f|
        Readline::HISTORY.each {|l| f.puts l }
      end
    end

    # For cleanin up JRuby's stack traces.
    BACKTRACE_HIDE = [ 'sun/', 'java/', 'org/jruby', 'interactive', ':', __FILE__ ]

    def print_backtrace(bt)
      bt.each do |t|
        unless BACKTRACE_HIDE.inject(false) do |flag,h|
            flag ||= starts_with(t, h)
          end
          puts "     #{t}"
        end
      end
    end

    def starts_with(long, short)
      long[0...short.length] == short
    end

    def get_candidates(binding, where='')
      candidates = []
      %w(methods constants local_variables).each do |m|
        begin
          candidates += eval(where + m, binding)
        rescue
        end
      end

      if where == ''
        eval('self.class.ancestors', binding).each do |an|
          %w(methods constants).each do |m|
            begin
              candidates += an.send(m)
            rescue
            end
          end
        end
      end

      return candidates.sort.uniq
    end
  end
end

if __FILE__ == $0
  include M

  puts "Interactive with a before and after hook"
  class MyInteractive < Interactive # :nodoc:
    def process_line(line)
      puts "This line is great: #{line}"
      line
    end

    def process_result(result)
      print " => "
      result
    end
  end
  MyInteractive.new.run
end

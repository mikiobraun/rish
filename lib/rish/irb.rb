# Copyright (c) 2010 by Mikio L. Braun
# rish is distributed under a BSD-style license. See COPYING

require 'irb'

module IRB
  # Start a rish-shell.
  #
  # This code is basically the same as IRB.start with the
  # irb object replaced by our own version.
  def IRB.rish_start(ap_path=nil, hook=nil)
    $0 = File::basename(ap_path, ".rb") if ap_path
    
    IRB.setup(ap_path)
    
    if @CONF[:SCRIPT]
      irb = Rish::Irb::RishIrb.new(nil, @CONF[:SCRIPT])
    else
      irb = Rish::Irb::RishIrb.new
    end

    irb.hook = hook

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    trap("SIGINT") do
      irb.signal_handle
    end
    
    catch(:IRB_EXIT) do
      irb.eval_input
    end
#    print "\n"
  end
end

module Rish
  # Rish's irb extensions.
  #
  # This module defines two classes derived from IRB::Irb and
  # IRB::Context which basically add after and before hooks
  # to the evaluation to implement automatic reloading and
  # profiling.
  module Irb
    # Our version of IRB::Irb which uses a RishContext.
    class RishIrb < IRB::Irb
      # Create new object.
      #
      # Overwrites @context to RishContext.
      def initialize(workspace = nil, input_method = nil, output_method = nil)
        super(workspace, input_method, output_method)
        @context = RishContext.new(self, workspace, input_method, output_method)
      end
      
      # Add a hook in the context object.
      def hook=(h)
        @context.hook = h
      end
    end
    
    # Our version of IRB::Context which adds before and after hooks
    # to evaluate.
    class RishContext < IRB::Context
      # Create new context object.

      def initialize(irb, workspace = nil, input_method = nil, output_method = nil)
        super(irb, workspace, input_method, output_method)
      end
      
      # Add a hook.
      def hook=(h)
        @hook = h
      end

      # Overwritten version of evaluate which calls the +before+ and
      # +after+ methods of the hook, if present. +before+ gets the
      # input line and may return a changed version, +after+ gets the
      # result and may return a changed version.
      def evaluate(line, line_no)
        line = @hook.before(line) if @hook
        val = super(line, line_no)
        val = @hook.after(val) if @hook
        val
      end
    end
  end
end

if __FILE__ == $0
  class RishHook # :nodoc:
    def before(line)
      puts "Before"
      line
    end
    
    def after(val)
      puts "After"
      val
    end
  end
  
  IRB.rish_start(nil, RishHook.new)
end

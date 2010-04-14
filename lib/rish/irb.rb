require 'irb'

module IRB
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
  module Irb
    class RishIrb < IRB::Irb
      def initialize(workspace = nil, input_method = nil, output_method = nil)
        super(workspace, input_method, output_method)
        @context = RishContext.new(self, workspace, input_method, output_method)
      end
      
      def hook=(h)
        @context.hook = h
      end
    end
    
    class RishContext < IRB::Context
      def initialize(irb, workspace = nil, input_method = nil, output_method = nil)
        super(irb, workspace, input_method, output_method)
      end
      
      def hook=(h)
        @hook = h
      end
      
      def evaluate(line, line_no)
        line = @hook.before(line) if @hook
        val = super(line, line_no)
        val = @hook.after(val) if @hook
        val
      end
    end
  end
end

class RishHook
  def before(line)
    puts "Before"
    line
  end

  def after(val)
    puts "After"
    val
  end
end

if __FILE__ == $0
  IRB.rish_start(nil, RishHook.new)
end

require 'profiler'

require 'rish/hook'
require 'rish/irb'
require 'rish/interactive'

class String # :nodoc:
  def starts_with?(s)
    self[0..s.length] == s
  end
end

module Rish
  module_function
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

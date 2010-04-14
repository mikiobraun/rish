module Rish
  module Commands
    module_function
    
    def help(word)
      puts %x{qri #{word}}
    end
  end
end

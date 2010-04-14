module Rish
  module Commands
    module_function
    
    def help(word=nil)
      if word
        puts %x{qri #{word}}
      else
        puts <<EOS
Rish builtin-commands

@p <expr>  profile expression (requires --debug on JRuby)
?<expr>    show help for command expr (doesn't work so well on IRB :( )
@h         show this help
!<cmd>     Run cmd in a shell
!<cmd> &   Run cmd in background 
!&<cmd>    Same as above (version for IRB which doesn't like an "&" 
           as last element on line)
EOS
      end
    end
  end
end

# Copyright (c) 2010 by Mikio L. Braun
# rish is distributed under a BSD-style license. See COPYING

module Rish
  # Collects commands which are available trough extensions.
  module Commands
    module_function
    
    # Show help for a command, or just the builtin commands.
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

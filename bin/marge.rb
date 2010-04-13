require 'marge/shell/shell'
require 'marge/shell/autoreload'

def banner
  puts <<EOS
    
                            Marge / Shell
               an autoreloading interactive shell with
             interactive help, shell-outs and profiling.

                      written by Mikio L. Braun

      Type doc 'expression' to get help on an object or method.
         Type 'exit' or hit Ctrl-D on an empty line to exit.

EOS
end

def usage
  puts <<EOS
Usage: marge [options] files_to_require.rb ...

Options:
  -a         : load all *.rb files in lib/ on startup
  -h, --help : show help (this)
EOS

end

until ARGV.empty?
  cmd = ARGV.shift
  case cmd
  when '-I'
    dir = ARGV.shift
    $: << dir
  when '-a'
    dir = ARGV.shift
    puts "Loading all ruby files in #{dir}/"
    Dir.glob("#{dir}/**/*.rb").each {|fn| require fn}
  when '-w'
    dir = ARGV.shift
    Marge::Shell::AutoReload.watch_directory dir
  when '-h', '--help'
    usage
    exit
  when '-e'
    cmd = ARGV.shift
    puts eval(cmd)
    exit
  else
    require cmd
  end
end

banner

Marge::Shell::AutoReload.check_directories

shell = Marge::Shell::MargeShell.new
shell.run
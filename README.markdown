marge/shell - interactive power shell for (j)ruby

marge/shell is a replacement for irb which has some nice features:

- ability to automatically reload files/watch directories for new
  files. That way, you can stay in your shell, keep all your data
  and play around with your files.

- Integrated help feature. Typing "?String" invokes qri (a faster
  ri replacement) and prints the help

- Shell-out. Typing "!ls" gives you a shell-out. With "!ls&" even
  as a background process.

- Profiling. With "@p some_really_long_running_function" invokes
  the expression and runs the profiler at the same time.

Other features I never used are missing, in particular debugging, and
sub-shells. At some point I'll probably hack the above features into
irb, but for now, this is all there is.


RUNNING MARGE

To invoke marge/shell, type "marge" at the command line. The following
options are available:

-I dir     : adds dir to the load path
-a dir     : loads all files in dir on startup
-h, --help : shows help
-e expr    : executes expression
-w dir     : watches dir for changes and automatically loads those
other	   : requires other

Files which are loaded ones are automatically watched for changes.

Through the "-I", "-a" and "-w" flags, you can use marge in a
project-dependent way. For example, you lay out your files as usual
like this:

  project/
          lib/
              somefile.rb
          README

Then, you can cd to project, and run "marge -I lib -w lib" to load
and watch all files in "lib" for changes.
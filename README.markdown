rish - Ruby interactive shell
=============================

Version 0.1, April 14, 2010

rush is a replacement for/extension of irb which has some nice
features:

- _Automatically reload files/watch directories for new
  files._ That way, you can stay in your shell, keep all your data
  and play around with your files.

- _Integrated help feature._ Typing `?String` invokes qri (a faster
  ri replacement) and prints the help

- _Shell-out._ Typing `!ls` gives you a shell-out. With `!ls&` even
  as a background process (or `!&ls` for the IRB mode)

- _Profiling._ With `@p some_really_long_running_function` invokes
  the expression and runs the profiler at the same time.

- Either runs as an extension of IRB or in it's own version which has
  less features (e.g. no debugging, no sub-shells, no multi-line
  edits), but integrates better with the above features.

Installing rish
---------------

Download the gem file and type

   > gem install rish-0.1.gem

Running rish
------------

To invoke rish, type `marge` at the command line. The following
options are available:

<pre>
-I dir     : adds dir to the load path
-a dir     : loads all files in dir on startup
-h, --help : shows help
-e expr    : executes expression
-w dir     : watches dir for changes and automatically loads those
--irb      : runs in IRB mode
--rish     : runs in rish's own interactive mode
other	   : requires other
</pre>

Files which are loaded ones are automatically watched for changes.

Through the "-I", "-a" and "-w" flags, you can use marge in a
project-dependent way. For example, you lay out your files as usual
like this:

<pre>
   project/
          lib/
              somefile.rb
          README
</pre>

Then, you can cd to project, and run "marge -I lib -w lib" to load
and watch all files in "lib" for changes.
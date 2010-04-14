# Copyright (c) 2010 by Mikio L. Braun
# rish is distributed under a BSD-style license. See COPYING

require 'pp'
require 'set'

module Rish
  # This module tracks loaded files and their timestamps and allows to reload
  # files which have changed automatically by calling reload.
  #
  # There is nothing magically happening here. Basically, you can
  # reload a file by removing it from $" (the list of all loaded
  # files) and require'ing it again.
  module Autoreload

    # stores the normalized filenames and their File.mtime timestamps
    @timestamps = Hash.new
    @notfound = Set.new
    @verbose = false
    @watched_dirs = []

    # Set verbosity flag. Setting this to true will report each file
    # that has been reloaded.
    def self.verbose=(flag)
      @verbose = flag
    end
    
    # Find the full path to a file.
    def self.locate(file)
      return nil if @notfound.include? file
      $:.each do |dir|
        fullpath = File.join(dir, file)
        if File.exists? fullpath
          return fullpath
        elsif File.exists?(fullpath + '.rb')
          return fullpath + '.rb'
        elsif File.exists?(fullpath + '.so')
          return fullpath + '.so'
        end
      end
      # puts "[JML::AutoReload] File #{file} not found!"
      @notfound.add file
      return nil
    end
    
    # Store the time stamp of a file.
    def self.timestamp(file)
      path = locate(file)
      if path
        file = normalize(path, file)
        @timestamps[file] = File.mtime(path)
      end
    end
    
    # Put the extension on a filename.
    def self.normalize(path, file)
      if File.extname(file) == ""
        return file + File.extname(path)
      else
        return file
      end
    end
    
    # Show all stored files and their timestamp.
    def self.dump
      pp @timestamps
    end
    
    # Reload a file. With force=true, file is reloaded in
    # any case.
    def self.reload(file, force=false)
      path = locate(file)
      file = normalize(path, file)
      
      if force or (path and File.mtime(path) > @timestamps[file])
        puts "[JML::AutoReload] reloading #{file}" if @verbose
        
        # delete file from list of loaded modules, and reload
        $".delete file
        require file
        return true
      else
        return false
      end
    end
    
    # Reload all files which were required.
    def self.reload_all(force=false)
      @timestamps.each_key do |file|
        self.reload(file, force)
      end
      check_directories
    end
    
    # Add directories to be watched.
    def self.watch_directory(dir)
      @watched_dirs << dir
    end
    
    # Reload any new files in the watched directories.
    def self.check_directories
      @watched_dirs.each do |dir|
        Dir.glob("#{dir}/**/*.rb").each do |fn| 
          if @timestamps.include? fn
            reload(fn)
          else
            require(fn)
          end
        end
      end
    end
  end
end

# Overwrite 'require' to register the time stamps instead.
module Kernel # :nodoc:
  alias old_require require
  
  def require(file)
    Rish::Autoreload.timestamp(file)
    old_require(file)
  end
end

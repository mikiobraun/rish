# -*- ruby -*-
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'marge'
  s.author = "Mikio L. Braun"
  s.email = "mikiobraun@gmail.com"
  s.homepage = ""
  s.version = "0.1"
  s.summary = "marge - machine learning toolbox"
  s.platform = Gem::Platform::RUBY
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = Dir.glob('lib/**/*.rb') + Dir.glob('lib/marge/jars/*.jar')
  s.bindir = 'bin'
  s.executables = [ 'marge', 'marge_runner.sh' ]
  s.has_rdoc = true
  s.description = "whatever I need to keep me going ;)"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc 'run all tests in the test directory'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = Dir.glob('test/**/*_test.rb')
  #t.verbose = true
end

desc 'compile java project'
task :compile do
  puts %x(cd ../java; ant jar)
end

#--------------------------------------------------------------------
desc 'generate rdoc html and local files'
task :rdoc do
  sh 'rdoc -S -f html -x "test_*"'
  sh 'rdoc -r -x "test_*"'
  sh 'fastri-server -b'
end

desc 'generate rdoc html'
task 'rdoc-html' do
  sh 'rdoc -S -f html -x "test_*"'
end

PROJECT_DIR = File.join(ENV['HOME'], 'Active')

def copy_jar(project)
  cp "#{PROJECT_DIR}/#{project}/dist/#{project}.jar", 'lib/marge/jars/'
end

desc 'compile dependencies'
task 'compile-dependencies' do
  sh '(cd ../java; ant jar)'
  sh "(cd #{PROJECT_DIR}/plotml; ant jar)"
end


desc 'update dependencies by copying jar files'
task 'update-dependencies' => ['compile-dependencies'] do
  cp '../java/dist/marge-java.jar', 'lib/marge/jars/'
  copy_jar 'plotml'
end
# -*- ruby -*-

Gem::Specification.new do |s|
  s.name = 'rish'
  s.version = '0.1'
  s.summary = 'Ruby interactive shell'
  s.platform = Gem::Platform::RUBY
  s.author = 'Mikio L. Braun'
  s.email = 'mikiobraun@gmail.com'
  s.homepage = 'http://github.com/mikiobraun/rish'
  s.description = <<EOS
An interactive Ruby shell with auto-reloading, shell-outs, profiling,
and integrated help.
EOS
  s.files = Dir.glob('{bin,lib}/**/*')
  s.executables = 'rish'

  s.add_dependency 'fastri'
end

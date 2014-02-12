# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gon/version'

Gem::Specification.new do |s|
  s.name        = 'gon'
  s.version     = Gon::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['gazay']
  s.licenses    = ['MIT']
  s.email       = ['alex.gaziev@gmail.com']
  s.homepage    = 'https://github.com/gazay/gon'
  s.summary     = %q{Get your Rails variables in your JS}
  s.description = %q{If you need to send some data to your js files and you don't want to do this with long way trough views and parsing - use this force!}

  s.rubyforge_project = 'gon'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.add_runtime_dependency 'actionpack', '~> 2.3.0', '>= 2.3.0'
  s.add_runtime_dependency 'json', '~> 0'
  s.add_development_dependency 'rabl', '~> 0'
  s.add_development_dependency 'rabl-rails', '~> 0'
  s.add_development_dependency 'rspec', '~> 0'
  s.add_development_dependency 'jbuilder', '~> 0'
  s.add_development_dependency 'rake', '~> 0'
end

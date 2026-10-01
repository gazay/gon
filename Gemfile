source 'https://rubygems.org'

# Specify your gem's dependencies in gon.gemspec
gem 'concurrent-ruby', '< 1.3.5' if ENV['RAILS_VERSION'] && ENV['RAILS_VERSION'].to_f < 7.1
gem 'i18n', '< 1.15' if RUBY_VERSION < '3.2'
gem 'loofah', '2.20.0' if RUBY_VERSION < '2.5'
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.4')
  gem 'oj', '< 3.10.9'
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.7')
  gem 'oj', '< 3.14.3'
else
  gem 'oj'
end

gem 'rabl'
gem 'request_store' if ENV['RAILS_VERSION'] && ENV['RAILS_VERSION'].to_f < 5.2

if ENV['RAILS_VERSION']
  gem 'actionpack', "~> #{ENV['RAILS_VERSION']}.0"
  gem 'railties', "~> #{ENV['RAILS_VERSION']}.0"
end

gemspec

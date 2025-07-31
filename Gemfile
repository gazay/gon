source "https://rubygems.org"

# Specify your gem's dependencies in gon.gemspec
gem ENV['RABL_GEM'] || 'rabl'
gem 'concurrent-ruby', '< 1.3.5' if ENV['RAILS_VERSION'] && ENV['RAILS_VERSION'].to_f < 7.1
gem 'loofah', '2.20.0' if RUBY_VERSION < '2.5'

if ENV['RAILS_VERSION']
  gem 'railties', "~> #{ENV['RAILS_VERSION']}.0"
  gem 'actionpack', "~> #{ENV['RAILS_VERSION']}.0"
end

gemspec

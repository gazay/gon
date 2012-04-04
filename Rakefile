require 'rubygems'
require 'rake'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'uglifier'
require 'sprockets'
require 'haml'

require 'compass'

ASSETS_PATH = File.expand_path('./assets', __FILE__)

COFFEE = File.expand_path('./coffee', ASSETS_PATH)
TEMPLATES = File.expand_path('./templates', ASSETS_PATH)
SASS = File.expand_path('./sass', ASSETS_PATH)
IMAGES = File.expand_path('./images', ASSETS_PATH)

Compass.configuration.images_path = IMAGES

desc 'Build all assets'
task :build do |t, args|
  puts 'building asset files'

end



### Rake tasks ###

desc 'Run all tests by default'
task :default do
  system("rspec spec")
end


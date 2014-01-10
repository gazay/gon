require 'gon'
require 'jbuilder'
require 'rabl'
require 'rabl-rails'

# rabl has a conflict with rabl-rails as rabl-rails causes Rails
# to be defined. In order to run all specs at once, we'll need to
# load/unload rabl and rabl-rails whenever we switch from testing
# one to another.
def ensure_rabl_is_loaded
  Object.send(:remove_const, :RablRails) if defined? RablRails
  Object.send(:remove_const, :Rails) if defined? Rails
  unless defined? Rabl
    load 'rabl.rb'
    load 'rabl/version.rb'
    load 'rabl/helpers.rb'
    load 'rabl/partials.rb'
    load 'rabl/engine.rb'
    load 'rabl/builder.rb'
    load 'rabl/configuration.rb'
    load 'rabl/renderer.rb'
    load 'rabl/cache_engine.rb'
  end
end

# Unloads rabl and loads rabl-rails.
def ensure_rabl_rails_is_loaded
  Object.send(:remove_const, :Rabl) if defined? Rabl
  unless defined? RablRails
    load 'rabl-rails/template.rb'
    load 'rabl-rails/condition.rb'
    load 'rabl-rails/compiler.rb'
    load 'rabl-rails/renderers/base.rb'
    load 'rabl-rails/renderers/json.rb'
    load 'rabl-rails/renderer.rb'
    load 'rabl-rails/library.rb'
    load 'rabl-rails.rb'
  end
end

RSpec.configure do |config|
  config.before(:each) do
    @request = Thread.current['gon'] = Gon::Request.new({})
    allow(Gon).to receive(:current_gon).and_return(@request)
  end
end

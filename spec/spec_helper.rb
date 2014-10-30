require 'gon'

# We don't require rails for specs, but jbuilder works only in rails.
# And it checks version of rails. I've decided to configure jbuilder for rails v4
module Rails
  module VERSION
    MAJOR = 4
  end
end

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
    load 'rabl/sources.rb'
    load 'rabl/partials.rb'
    load 'rabl/multi_builder.rb'
    load 'rabl/builder.rb'
    load 'rabl/engine.rb'
    load 'rabl/configuration.rb'
    load 'rabl/renderer.rb'
    load 'rabl/cache_engine.rb'
  end
end

# Unloads rabl and loads rabl-rails.
def ensure_rabl_rails_is_loaded
  Object.send(:remove_const, :Rabl) if defined? Rabl
  unless defined? RablRails
    load 'rabl-rails/renderer.rb'
    load 'rabl-rails/helpers.rb'
    load 'rabl-rails/configuration.rb'
    load 'rabl-rails/nodes/node.rb'
    load 'rabl-rails/nodes/attribute.rb'
    load 'rabl-rails/compiler.rb'
    load 'rabl-rails/renderers/hash.rb'
    load 'rabl-rails/renderers/json.rb'
    load 'rabl-rails.rb'
    load 'rabl-rails/template.rb'
    load 'rabl-rails/library.rb'
  end
end

RSpec.configure do |config|
  config.before(:each) do
    RequestStore.store[:gon] = Gon::Request.new({})
    @request = RequestStore.store[:gon]
    allow(Gon).to receive(:current_gon).and_return(@request)
  end
end

if RUBY_VERSION > '1.9' && defined?(Jbuilder)
  gem 'blankslate'
end
require 'action_view'
require 'action_controller'
require 'gon/base'
require 'gon/request'
require 'gon/helpers'
require 'gon/escaper'
if defined?(Rabl)
  require 'gon/rabl'
end
if RUBY_VERSION > '1.9' && defined?(Jbuilder)
  require 'gon/jbuilder'
end

module Gon
  class << self

    def all_variables
      Request.gon
    end

    def clear
      Request.clear
    end

    def method_missing(method, *args, &block)
      if ( method.to_s =~ /=$/ )
        if public_method_name? method
          raise "You can't use Gon public methods for storing data"
        end

        set_variable(method.to_s.delete('='), args[0])
      else
        get_variable(method.to_s)
      end
    end

    def inspect
      'Gon'
    end

    private

    def get_variable(name)
      Request.gon[name]
    end

    def set_variable(name, value)
      Request.gon[name] = value
    end

    def public_method_name?(method)
      public_methods.include?(
        if RUBY_VERSION > '1.9'
          method.to_s[0..-2].to_sym
        else
          method.to_s[0..-2]
        end
      )
    end

  end
end

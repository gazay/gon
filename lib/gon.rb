require 'action_view'
require 'action_controller'
require 'gon/base'
require 'gon/global'
require 'gon/watch'
require 'gon/request'
require 'gon/helpers'
require 'gon/escaper'
require 'gon/rabl'
require 'gon/jbuilder'

class Gon
  class << self

    def global
      Gon::Global
    end

    def watch
      Gon::Watch
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

    def get_variable(name)
      Request.gon[name]
    end

    def set_variable(name, value)
      Request.gon[name] = value
    end

    def push(data = {})
      raise "Object must have each_pair method" unless data.respond_to? :each_pair

      data.each_pair do |name, value|
        set_variable(name.to_s, value)
      end
    end

    def all_variables
      Request.gon
    end

    def clear
      Request.clear
    end

    def rabl(*args)
      data, options = Gon::Rabl.handler(args)
      store_builder_data 'rabl', data, options
    end

    def jbuilder(*args)
      ensure_template_handler_is_defined
      data, options = Gon::Jbuilder.handler(args)
      store_builder_data 'jbuilder', data, options
    end

    def inspect
      'Gon'
    end

    private

    def store_builder_data(builder, data, options)
      if options[:as]
        set_variable(options[:as].to_s, data)
      elsif data.is_a? Hash
        data.each do |key, value|
          set_variable(key, value)
        end
      else
        set_variable(builder, data)
      end
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

    # JbuilderTemplate will not be defined if jbuilder is required
    # before gon. By loading jbuilder again, JbuilderTemplate will
    # now be defined
    def ensure_template_handler_is_defined
      load 'jbuilder.rb' unless defined?(JbuilderTemplate)
    end

  end
end

require 'action_view'
require 'action_controller'
require 'gon/helpers'
require 'gon/rabl'

module Gon
  class << self
    def all_variables
      @request_env[:gon]
    end

    def clear
      @request_env[:gon] = {}
    end

    def request_env=(request_env)
      @request_env = request_env
      @request_env[:gon] ||= {}
    end

    def request_env
      if defined?(@request_env)
        return @request_env
      end
    end

    def method_missing(m, *args, &block)
      if ( m.to_s =~ /=$/ )
        if public_methods.include? m.to_s[0..-2].to_sym
          raise "You can't use Gon public methods for storing data"
        end
        set_variable(m.to_s.delete('='), args[0])
      else
        get_variable(m.to_s)
      end
    end

    def get_variable(name)
      @request_env[:gon][name]
    end

    def set_variable(name, value)
      @request_env[:gon][name] = value
    end

    def rabl(view_path, options = {})
      # if rabl_name = options[:as] || options[:to]
        
      # end
      set_variable('rabl', Gon::Rabl.parse_rabl(view_path, @request_env['action_controller.instance']))
    end
  end
end

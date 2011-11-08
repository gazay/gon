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
      rabl_data = Gon::Rabl.parse_rabl(view_path, options[:controller] || 
                                                  @request_env['action_controller.instance'] || 
                                                  @request_env['action_controller.rescue.response'].
                                                    instance_variable_get('@template').
                                                    instance_variable_get('@controller'))
      if options[:as]
        set_variable(options[:as].to_s, rabl_data)
      elsif rabl_data.is_a? Hash
        rabl_data.each do |key, value|
          set_variable(key, value)
        end
      else
        set_variable('rabl', rabl_data)
      end
    end
  end
end

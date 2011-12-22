gem 'blankslate'
require 'action_view'
require 'action_controller'
require 'gon/helpers'
require 'gon/rabl'
if RUBY_VERSION =~ /9/ && defined?(Jbuilder)
  require 'gon/jbuilder'
end

module Gon
  class << self
    def all_variables
      @request_env[:gon]
    end

    def clear
      @request_env[:gon] = {}
    end

    def request_env=(environment)
      @request_env = environment
      @request_env[:gon] ||= {}
    end

    def request_env
      if defined?(@request_env)
        return @request_env
      end
    end

    def request
      @request_id if defined? @request_id
    end

    def request=(request_id)
      @request_id = request_id      
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

    def jbuilder(view_path, options = {})
      if RUBY_VERSION !~ /9/
        raise NoMethodError.new('You can use Jbuilder support only in 1.9+') 
      elsif !defined?(Gon::Jbuilder)
        raise NoMethodError.new('You should define Jbuilder in your Gemfile') 
      end

      jbuilder_data = Gon::Jbuilder.parse_jbuilder(view_path, options[:controller] || 
                                                  @request_env['action_controller.instance'] || 
                                                  @request_env['action_controller.rescue.response'].
                                                    instance_variable_get('@template').
                                                    instance_variable_get('@controller'))
      if options[:as]
        set_variable(options[:as].to_s, jbuilder_data)
      elsif jbuilder_data.is_a? Hash
        jbuilder_data.each do |key, value|
          set_variable(key, value)
        end
      else
        set_variable('jbuilder', jbuilder_data)
      end
    end
  end
end

require 'action_view'
require 'action_controller'
require 'gon/helpers'

module Gon
  def self.all_variables
    @request_env[:gon]
  end

  def self.clear
    @request_env[:gon] = {}
  end

  def self.request_env=(request_env)
    @request_env = request_env
  end

  def self.request_env
    if defined?(@request_env)
      return @request_env
    end
  end

  def self.method_missing(m, *args, &block)
    @request_env[:gon] ||= {}

    if ( m.to_s =~ /=/ )
      set_variable(m.to_s.delete('='), args[0])
    else
      get_variable(m.to_s)
    end
  end

  def self.get_variable(name)
    @request_env[:gon][name]
  end

  def self.set_variable(name, value)
    @request_env[:gon][name] = value
  end
end

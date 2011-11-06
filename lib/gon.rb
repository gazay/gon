require 'action_view'
require 'action_controller'
require 'gon/helpers'
require 'gon/partial'

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

    if ( m.to_s =~ /=$/ )
      if self.public_methods.include? m.to_s[0..-2].to_sym
        raise "You can't use Gon public methods for storing data"
      end
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

  def self.[](object)
    request_env[:partials] ||= {}
    request_env[:partials][object] ||= Gon::Partial.new
  end
end

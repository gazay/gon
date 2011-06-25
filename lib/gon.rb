require 'action_view'
require 'gon/helpers'

module Gon
  def self.all_variables
    request.env[:gon]
  end
  def self.clear
    request.env[:gon] = {}
  end
  
  def self.method_missing(m, *args, &block)
    request.env[:gon] ||= {}
      
    if ( m.to_s =~ /=/ )
      set_variable(m.to_s.delete('='), args[0])
    else
      get_variable(m.to_s)
    end
  end

  def self.get_variable(name)
    request.env[:gon][name]
  end

  def self.set_variable(name, value)
    request.env[:gon][name] = value
  end
end

require 'action_view'
require 'gon/helpers'

module Gon
  def self.method_missing(m, *args, &block)
    gon_variables(m.to_s, args[0])
  end
  
  def self.gon_variables(name=nil, value=nil)
    data = Rails.cache.read('gon_variables') || {}
    
    new_data = {}
    new_data[name] = value if name && value
    
    Rails.cache.delete('gon_variables')
    Rails.cache.write('gon_variables', (new_data.merge data))
  end
end

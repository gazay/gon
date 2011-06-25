require 'action_view'
require 'gon/helpers'
require 'ostruct'

self.class.send(:remove_const, 'Gon') if self.class.const_defined? 'Gon'
self.class.const_set 'Gon', OpenStruct.new

class << Gon
  def all_variables
    @table
  end
  def clear
    @table = {}
  end
end

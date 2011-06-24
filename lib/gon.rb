require 'action_view'
require 'gon/helpers'
require 'ostruct'

Gon = OpenStruct.new

class << Gon
  def all_variables
    @table
  end
  def clear
    @table = {}
  end
end

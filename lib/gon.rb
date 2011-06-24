require 'action_view'
require 'gon/helpers'
require 'ostruct'

Gon = OpenStruct.new

class << Gon
  def all_variables
    instance_variable_get :@table
  end
  def clear
    instance_variable_set :@table, {}
  end
end

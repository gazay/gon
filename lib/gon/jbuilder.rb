require 'jbuilder'

module Gon
  module Jbuilder
    class << self
      def parse_jbuilder(jbuilder_path, controller)
        source = File.read(jbuilder_path)
        controller.instance_variables.each do |name|
          self.instance_variable_set(name, controller.instance_variable_get(name))
        end
        output = ::JbuilderTemplate.encode(controller) do |json|
          eval source
        end
        JSON.parse(output)
      end
    end
  end
end

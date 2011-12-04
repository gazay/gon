require 'rabl'

module Gon
  module Rabl
    class << self
      def parse_rabl(rabl_path, controller)
        source = File.read(rabl_path)
        rabl_engine = ::Rabl::Engine.new(source, :format => 'json')
        output = rabl_engine.render(controller, {})
        JSON.parse(output)
      end
    end
  end
end

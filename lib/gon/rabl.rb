require 'rabl'

module Gon::Rabl
  class << self
    def parse_rabl(rabl_path, controller)
      source = File.read(rabl_path)
      rabl_engine = Rabl::Engine.new(source, :format => 'json')
      output = rabl_engine.render(controller, {})
      
    end
  end
end

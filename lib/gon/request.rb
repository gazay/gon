class Gon
  class Request
    attr_reader :env
    attr_accessor :id

    def initialize(environment)
      @env = environment
      @gon = {}
    end

    def gon
      @gon
    end

    def clear
      @gon = {}
    end

  end
end

class Gon
  class Request
    attr_reader :env

    def initialize(environment)
      @env = environment
      @gon = {}
    end

    def id
      @request_id
    end

    def id=(request_id)
      @request_id = request_id
    end

    def gon
      @gon
    end

    def clear
      @gon = {}
    end

  end
end

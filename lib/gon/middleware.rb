class Gon
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      env['gon'] = Thread.current['gon'] = Request.new(env)
      Gon.clear
      @app.call(env)
    end
  end
end

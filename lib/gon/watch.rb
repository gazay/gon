class Gon
  class Watch
    class << self

      def method_missing(method, *args, &block)
        @return = return_variable?(method)
        Gon.send method, *args, &block
      end

      def clear
        @return = false
      end

      def need_return?
        defined?(@return) and @return
      end

      def return_variable(value)
        controller = Gon::Base.get_controller

        controller.render :json => value
      end

      private

      def return_variable?(variable)
        controller = Gon::Base.get_controller
        params = controller.params
        variable = variable.to_s.gsub('=', '')

        controller.request.xhr? &&
          params[:gon_return_variable] &&
          params[:gon_watched_variable] == variable
      end

    end
  end
end

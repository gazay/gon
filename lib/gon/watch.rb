class Gon
  class Watch
    class << self

      def all_variables
        @watch_variables || {}
      end

      def clear
        @watch_variables = {}
      end

      def need_return?
        defined?(@return) and @return
      end

      def return_variable(value)
        controller = Gon::Base.get_controller

        controller.render :json => value
      end

      private

      def method_missing(method, *args, &block)
        if return_variable?(method)
          Gon.send method, *args, &block
        end
      end

      def return_variable?(variable)
        return false if variable !~ /=$/

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

class Gon
  module Helpers

    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods

      def include_gon(options = {})
        if variables_for_request_present?
          Gon::Base.render_data(options)
        elsif Gon.global.all_variables.present?
          Gon.clear
          Gon::Base.render_data(options)
        elsif options[:init].present?
          Gon.clear
          Gon::Base.render_data(options)
        else
          ''
        end
      end

      private

      def variables_for_request_present?
        current_gon && current_gon.gon
      end

      def current_gon
        Thread.current['gon']
      end

    end
  end

  module GonHelpers

    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods

      def gon
        if wrong_gon_request?
          gon_request = Request.new(env)
          gon_request.id = request.uuid
          Thread.current['gon'] = gon_request
        end
        Gon
      end

      private

      def wrong_gon_request?
        current_gon.blank? || current_gon.id != request.uuid
      end

      def current_gon
        Thread.current['gon']
      end

    end
  end
end

ActionView::Base.send :include, Gon::Helpers
ActionController::Base.send :include, Gon::GonHelpers

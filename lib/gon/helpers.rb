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
          Gon.clear if Gon.all_variables.present?
          Gon::Base.render_data(options)
        else
          ""
        end
      end

      private

      def variables_for_request_present?
        Gon::Request.env &&
        Gon::Request.id == request.object_id &&
        Gon.all_variables.present?
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
          Gon::Request.id = request.object_id
          Gon::Request.env = request.env
        end
        Gon
      end

      private

      def wrong_gon_request?
        Gon::Request.env.blank? ||
        Gon::Request.id != request.object_id
      end

    end

  end
end

ActionView::Base.send :include, Gon::Helpers
ActionController::Base.send :include, Gon::GonHelpers

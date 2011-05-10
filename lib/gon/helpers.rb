module Gon
  module Helpers
    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def include_gon
        data = Rails.cache.read('gon_variables') || {}

        script = "<script>function Gon(){"
        data.each do |key, val|
          script += "this." + key.to_s + val.to_json + ";"
        end
        script += "}; var Gon = new Gon()</script>"
        script.html_safe
      end
    end

  end
end

module ActionView::Helpers
  include Gon::Helpers
end

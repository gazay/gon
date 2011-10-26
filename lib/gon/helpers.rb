module Gon
  module Helpers
    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def include_gon(camel_case = false)
        if Gon.request_env
          data = Gon.all_variables

          script = "<script>window.gon = {};"
          unless camel_case
            data.each do |key, val|
              script += "gon." + key.to_s + '=' + val.to_json + ";"
            end
          else
            data.each do |key, val|
              script += "gon." + key.to_s.camelize(:lower) + '=' + val.to_json + ";"
            end
          end
          script += "</script>"
          script.html_safe
        else
          ""
        end
      end
    end
  end

  module GonHelpers
    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def gon
        if !Gon.request_env || Gon.request_env.object_id != request.env.object_id
          Gon.request_env = request.env
        end
        Gon
      end
    end
  end
end

ActionView::Base.send :include, Gon::Helpers
ActionController::Base.send :include, Gon::GonHelpers
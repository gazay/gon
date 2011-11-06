module Gon
  module Helpers
    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def include_gon(options = {})
        if Gon.request_env
          data = Gon.all_variables
          namespace = options[:namespace] || 'gon'
          script = "<script>window." + namespace + " = {};"
          unless options[:camel_case]
            data.each do |key, val|
              script += namespace + "." + key.to_s + '=' + val.to_json + ";"
            end
          else
            data.each do |key, val|
              script += namespace + "." + key.to_s.camelize(:lower) + '=' + val.to_json + ";"
            end
          end
          script += partials_js(namespace)
          script += "</script>"
          script.html_safe
        else
          ""
        end
      end
      
      def gon_partials(object, options = {})
        if Gon.request_env
          data = Gon[object].all_variables
          attribute = "data-gon-partial={"
          unless options[:camel_case]
            data.each do |key, val|
              attribute += '"' + key.to_s + '":' + val.to_json + ","
            end
          else
            data.each do |key, val|
              attribute += '"' + key.to_s.camelize(:lower) + '":' + val.to_json + ","
            end
          end
          attribute = attribute[0..-2] + "}"
          attribute.html_safe
        end        
      end

      def partials_js(namespace)
        "window." + namespace + ".getPartial = function(domObject) {" +
          "data = domObject.getAttribute('data-gon-partial');" + 
          "return JSON.parse(data);" +
        "};"
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

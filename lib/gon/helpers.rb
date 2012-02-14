module Gon
  module Helpers
    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def include_gon(options = {})
        if Gon.request_env && Gon.all_variables.present?
          data = Gon.all_variables
          namespace = options[:namespace] || 'gon'
          script = '<script>window.' + namespace + ' = {};'
          if options[:camel_case]
            data.each do |key, val|
              script << namespace + '.' + key.to_s.camelize(:lower) + '=' + val.to_json + ';'
            end
          else
            data.each do |key, val|
              script << namespace + '.' + key.to_s + '=' + val.to_json + ';'
            end
          end
          script << '</script>'
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
        if !Gon.request_env || Gon.request != request.object_id
          Gon.request = request.object_id
          Gon.request_env = request.env
        end
        Gon
      end
    end
  end
end

ActionView::Base.send :include, Gon::Helpers
ActionController::Base.send :include, Gon::GonHelpers

module Gon
  module Helpers
    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def include_gon
        javascript_include_tag 'http://gaziev.com/files/gon.js'
      end

      def gon_variables
        data = Rails.cache.read('gon_variables') || {}

        data.to_s.gsub('=>', ' : ')
      end
    end

  end
end

module ActionView::Helpers
  include Gon::Helpers
end

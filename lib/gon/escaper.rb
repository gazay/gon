class Gon
  module Escaper
    extend ActionView::Helpers::JavaScriptHelper
    extend ActionView::Helpers::TagHelper

    class << self

      def escape_unicode(javascript)
        if javascript
          result = javascript.gsub(/\342\200\250/u, '&#x2028;').gsub(/(<\/)/u, '\u003C/')
          javascript.html_safe? ? result.html_safe : result
        else
          ''
        end
      end

    end
  end
end

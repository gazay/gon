class Gon
  module Escaper
    extend ActionView::Helpers::JavaScriptHelper
    extend ActionView::Helpers::TagHelper

    class << self

      def escape_unicode(javascript)
        if javascript
          result = javascript.gsub(/\\u2028/u, '&#x2028;').gsub(/(<\/)/u, '\u003C/')
          javascript.html_safe? ? result.html_safe : result
        end
      end

      def javascript_tag(content, type, cdata)
        type = { type: 'text/javascript' } if type
        content_tag(:script, javascript_cdata_section(content, cdata).html_safe, type)
      end

      def javascript_cdata_section(content, cdata)
        if cdata
          "\n//#{cdata_section("\n#{content}\n//")}\n"
        else
          "\n#{content}\n"
        end
      end

    end
  end
end

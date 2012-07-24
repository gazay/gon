class Gon
  module Escaper
    class << self

      GON_JS_ESCAPE_MAP = {
        '</'    => '\u003C/'
      }

      def escape(javascript)
        if javascript
          result = javascript.gsub(/(<\/)/u) {|match| GON_JS_ESCAPE_MAP[match] }
          javascript.html_safe? ? result.html_safe : result
        else
          ''
        end
      end

    end
  end
end

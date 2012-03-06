module Gon
  module Helpers

    def self.included base
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def include_gon(options = {})
        if Gon.request_env && Gon.all_variables.present? && Gon.request == request.object_id
          data = Gon.all_variables
          namespace = options[:namespace] || 'gon'
          start = '<script>window.' + namespace + ' = {};'
          script = ''
          if options[:camel_case]
            data.each do |key, val|
              script << namespace + '.' + key.to_s.camelize(:lower) + '=' + val.to_json + ';'
            end
          else
            data.each do |key, val|
              script << namespace + '.' + key.to_s + '=' + val.to_json + ';'
            end
          end
          script = start + escape_javascript(script) + '</script>'
          script.html_safe
        else
          ""
        end
      end

      unless self.respond_to? :escape_javascript
        # Just add helper from rails 3-2-stable

        JS_ESCAPE_MAP = {
          '\\'    => '\\\\',
          '</'    => '<\/',
          "\r\n"  => '\n',
          "\n"    => '\n',
          "\r"    => '\n',
          '"'     => '\\"',
          "'"     => "\\'"
        }

        if "ruby".encoding_aware?
          JS_ESCAPE_MAP["\342\200\250".force_encoding('UTF-8').encode!] = '&#x2028;'
        else
          JS_ESCAPE_MAP["\342\200\250"] = '&#x2028;'
        end

        # Escapes carriage returns and single and double quotes for JavaScript segments.
        #
        # Also available through the alias j(). This is particularly helpful in JavaScript responses, like:
        #
        #   $('some_element').replaceWith('<%=j render 'some/element_template' %>');
        def escape_javascript(javascript)
          if javascript
            result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|[\n\r"'])/u) {|match| JS_ESCAPE_MAP[match] }
            javascript.html_safe? ? result.html_safe : result
          else
            ''
          end
        end

        alias_method :j, :escape_javascript
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

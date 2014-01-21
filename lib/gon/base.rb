class Gon
  module Base
    class << self

      def render_data(options)
        namespace, tag, cameled, camel_depth, watch, type, cdata = parse_options(options)
        script = "window.#{namespace}={};"

        script << formatted_data(namespace, cameled, camel_depth, watch)
        script = Gon::Escaper.escape_unicode(script)
        script = Gon::Escaper.javascript_tag(script, type, cdata) if tag

        script.html_safe
      end

      def get_controller(options = {})
        options[:controller] ||
          (
            current_gon &&
            current_gon.env['action_controller.instance'] ||
            current_gon.env['action_controller.rescue.response'].
              instance_variable_get('@template').
              instance_variable_get('@controller')
          )
      end

      def get_template_path(options, extension)
        if options[:template]
          if right_extension?(extension, options[:template])
            options[:template]
          else
            [options[:template], extension].join('.')
          end
        else
          controller = get_controller(options).controller_path
          action = get_controller(options).action_name
          "app/views/#{controller}/#{action}.json.#{extension}"
        end
      end

      private

      def current_gon
        Thread.current[:gon]
      end

      def parse_options(options)
        namespace   = options[:namespace] || 'gon'
        need_tag    = options[:need_tag].nil? || options[:need_tag]
        cameled     = options[:camel_case]
        camel_depth = options[:camel_depth] || 1
        watch       = options[:watch]
        tag         = need_tag
        type        = options[:type].nil? || options[:type]
        cdata       = options[:cdata].nil? || options[:cdata]

        [namespace, tag, cameled, camel_depth, watch, type, cdata]
      end

      def formatted_data(namespace, keys_cameled, camel_depth, watch)
        script = ''

        gon_variables.each do |key, val|
          js_key = keys_cameled ? key.to_s.camelize(:lower) : key.to_s
          script << "#{namespace}.#{js_key}=#{to_json(val, camel_depth)};"
        end

        if watch and Gon::Watch.all_variables.present?
          script << Gon.watch.render
        end

        script
      end

      def to_json(value, camel_depth)
        # starts at two because 1 is the root key which is converted in the formatted_data method
        convert_hash_keys(value, 2, camel_depth).to_json
      end

      def convert_hash_keys(value, current_depth, max_depth)
        return value if current_depth > (max_depth.is_a?(Symbol) ? 1000 : max_depth)
        return value unless value.is_a? Hash

        Hash[value.map { |k, v|
          [ k.to_s.camelize(:lower), convert_hash_keys(v, current_depth + 1, max_depth) ]
        }]
      end

      def gon_variables
        data = Gon.all_variables || {}

        if Gon.global.all_variables.present?
          data[:global] = Gon.global.all_variables
        end

        data
      end

      def right_extension?(extension, template_path)
        File.extname(template_path) == ".#{extension}"
      end

    end
  end
end

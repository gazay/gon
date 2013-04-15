class Gon
  module Base
    class << self

      def render_data(options)
        namespace, tag, cameled, watch = parse_options options
        script    = "window.#{namespace} = {};"

        script << formatted_data(namespace, cameled, watch)
        script = Gon::Escaper.escape_unicode(script)
        script = Gon::Escaper.javascript_tag(script) if tag

        script.html_safe
      end

      def get_controller(options = {})
        options[:controller] ||
          Gon::Request.env['action_controller.instance'] ||
          Gon::Request.env['action_controller.rescue.response'].
          instance_variable_get('@template').
          instance_variable_get('@controller')
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

      def parse_options(options)
        namespace  = options[:namespace] || 'gon'
        need_tag   = options[:need_tag].nil? || options[:need_tag]
        cameled    = options[:camel_case]
        watch      = options[:watch]
        tag        = need_tag

        [namespace, tag, cameled, watch]
      end

      def formatted_data(namespace, keys_cameled, watch)
        script = ''

        gon_variables.each do |key, val|
          js_key = keys_cameled ? key.to_s.camelize(:lower) : key.to_s
          script << "#{namespace}.#{js_key}=#{val.to_json};"
        end

        if watch and Gon::Watch.all_variables.present?
          script << Gon.watch.render
        end

        script
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

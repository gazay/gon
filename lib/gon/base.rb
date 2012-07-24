class Gon
  module Base
    class << self

      def render_data(options)
        data = Gon.all_variables || {}
        if Gon.global.all_variables.present?
          data[:global] = Gon.global.all_variables
        end
        namespace, tag, cameled, watch = parse_options options
        start     = "#{tag if tag}window.#{namespace} = {};"
        script    = ''

        data.each do |key, val|
          if cameled
            script << "#{namespace}.#{key.to_s.camelize(:lower)}=#{val.to_json};"
          else
            script << "#{namespace}.#{key.to_s}=#{val.to_json};"
          end
        end

        script = start + Gon::Escaper.escape(script)
        script << Gon.watch.render if watch and Gon::Watch.all_variables.present?
        script << '</script>' if tag
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
        need_type  = options[:need_type].present? && options[:need_type]
        cameled    = options[:camel_case]
        watch      = options[:watch]
        tag = need_tag && (need_type ? '<script type="text/javascript">' : '<script>')

        [namespace, tag, cameled, watch]
      end

      def right_extension?(extension, template_path)
        File.extname(template_path) == ".#{extension}"
      end

    end
  end
end

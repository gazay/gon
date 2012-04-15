module Gon
  module Base
    class << self

      def render_data(options)
        data = Gon.all_variables.merge(Gon.global.all_variables)
        namespace = options[:namespace] || 'gon'
        start = '<script>window.' + namespace + ' = {};'
        script = ''

        if options[:camel_case]
          data.each do |key, val|
            script << "#{namespace}.#{key.to_s.camelize(:lower)}=#{val.to_json};"
          end
        else
          data.each do |key, val|
            script << "#{namespace}.#{key.to_s}=#{val.to_json};"
          end
        end

        script = start + Gon::Escaper.escape(script) + '</script>'
        script.html_safe
      end

      def get_controller(options)
        options[:controller] ||
          @request_env['action_controller.instance'] ||
          @request_env['action_controller.rescue.response'].
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

      def right_extension?(extension, template_path)
        File.extname(template_path) == ".#{extension}"
      end

    end
  end
end

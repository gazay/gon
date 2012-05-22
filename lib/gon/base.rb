module Gon
  module Base
    class << self

      def render_data(options)
        if Gon.global.all_variables.present?
          Gon::Request.gon['global'] = Gon.global.all_variables
        end
        data = Gon.all_variables
        namespace = options[:namespace] || 'gon'
        need_tag = options[:need_tag].nil? || options[:need_tag]
        start = "#{need_tag ? '<script>' : ''}window.#{namespace} = {};"
        script = ''

        if data.present?
          if options[:camel_case]
            data.each do |key, val|
              script << "#{namespace}.#{key.to_s.camelize(:lower)}=#{val.to_json};"
            end
          else
            data.each do |key, val|
              script << "#{namespace}.#{key.to_s}=#{val.to_json};"
            end
          end
        end

        script = start + Gon::Escaper.escape(script)
        script << '</script>' if need_tag
        script.html_safe
      end

      def get_controller(options)
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

      def right_extension?(extension, template_path)
        File.extname(template_path) == ".#{extension}"
      end

    end
  end
end

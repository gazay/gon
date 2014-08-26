class Gon
  module Base
    ENV_CONTROLLER_KEY = 'action_controller.instance'

    class << self

      def render_data(options)
        namespace, tag, cameled, camel_depth, watch, type, cdata, global_root, namespace_check = parse_options(options)
        script = namespace_check ? "window.#{namespace}=window.#{namespace}||{};" : "window.#{namespace}={};"

        script << formatted_data(namespace, cameled, camel_depth, watch, global_root)
        script = Gon::Escaper.escape_unicode(script)
        script = Gon::Escaper.javascript_tag(script, type, cdata) if tag

        script.html_safe
      end

      def render_data_amd(options)
        namespace, tag, cameled, camel_depth, watch, type, cdata, global_root = parse_options(options)

        script = "define('#{namespace}',[],function(){" 
        script << amd_formatted_data(namespace, cameled, camel_depth, watch, global_root)
        script << 'return gon;});'

        script = Gon::Escaper.escape_unicode(script)
        script = Gon::Escaper.javascript_tag(script, type, cdata) if tag

        script.html_safe
      end

      def get_controller(options = {})
        options[:controller] ||
          (
            current_gon &&
            current_gon.env[Gon::Base::ENV_CONTROLLER_KEY] ||
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
        RequestStore.store[:gon]
      end

      def parse_options(options)
        namespace   = options[:namespace] || 'gon'
        need_tag    = options[:need_tag].nil? || options[:need_tag]
        cameled     = options[:camel_case]
        camel_depth = options[:camel_depth] || 1
        watch       = options[:watch] || !Gon.watch.all_variables.empty?
        tag         = need_tag
        type        = options[:type].nil? || options[:type]
        cdata       = options[:cdata].nil? || options[:cdata]
        global_root = options.has_key?(:global_root) ? options[:global_root] : 'global'
        namespace_check = options.has_key?(:namespace_check) ? options[:namespace_check] : false

        [namespace, tag, cameled, camel_depth, watch, type, cdata, global_root, namespace_check]
      end

      def formatted_data(namespace, keys_cameled, camel_depth, watch, global_root)
        script = ''

        gon_variables(global_root).each do |key, val|
          js_key = keys_cameled ? key.to_s.camelize(:lower) : key.to_s
          script << "#{namespace}.#{js_key}=#{to_json(val, camel_depth)};"
        end

        if watch and Gon::Watch.all_variables.present?
          script << Gon.watch.render
        end

        script
      end

      def amd_formatted_data(namespace, keys_cameled, camel_depth, watch, global_root)
        script = 'var gon={};'

        gon_variables(global_root).each do |key, val|
          js_key = keys_cameled ? key.to_s.camelize(:lower) : key.to_s
          script << "gon['#{js_key}']=#{to_json(val, camel_depth)};"
        end

        if watch and Gon::Watch.all_variables.present?
          script << Gon.watch.render_amd
        end

        script
      end

      def to_json(value, camel_depth)
        # starts at 2 because 1 is the root key which is converted in the formatted_data method
        Gon::JsonDumper.dump convert_hash_keys(value, 2, camel_depth)
      end

      def convert_hash_keys(value, current_depth, max_depth)
        return value if current_depth > (max_depth.is_a?(Symbol) ? 1000 : max_depth)

        case value
          when Hash
            Hash[value.map { |k, v|
              [ k.to_s.camelize(:lower), convert_hash_keys(v, current_depth + 1, max_depth) ]
            }]
          when Enumerable
            value.map { |v| convert_hash_keys(v, current_depth + 1, max_depth) }
          else
            value
        end
      end

      def gon_variables(global_root)
        data = {}

        if Gon.global.all_variables.present?
          if global_root.blank?
            data = Gon.global.all_variables
          else
            data[global_root.to_sym] = Gon.global.all_variables
          end
        end

        data.merge(Gon.all_variables)
      end

      def right_extension?(extension, template_path)
        File.extname(template_path) == ".#{extension}"
      end

    end
  end
end

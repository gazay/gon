require 'ostruct'

class Gon
  module Base
    ENV_CONTROLLER_KEY = 'action_controller.instance'
    VALID_OPTION_DEFAULTS = {
        namespace: 'gon',
        camel_case: false,
        camel_depth: 1,
        watch: false,
        need_tag: true,
        type: true,
        cdata: true,
        global_root: 'global',
        namespace_check: false
    }

    class << self

      def render_data(options)
        _o = define_options(options)
        _o.amd = false
        script = \
          if _o.namespace_check
            "window.#{_o.namespace}=window.#{_o.namespace}||{};"
          else
            "window.#{_o.namespace}={};"
          end

        script << formatted_data(_o)
        script = Gon::Escaper.escape_unicode(script)
        script = Gon::Escaper.javascript_tag(script, _o.type, _o.cdata) if _o.tag

        script.html_safe
      end

      def render_data_amd(options)
        _o = define_options(options)
        _o.amd = true

        script = "define('#{_o.namespace}',[],function(){"
        script << formatted_data(_o)
        script << 'return gon;});'

        script = Gon::Escaper.escape_unicode(script)
        script = Gon::Escaper.javascript_tag(script, _o.type, _o.cdata) if _o.tag

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

      def define_options(options)
        _o = OpenStruct.new

        VALID_OPTION_DEFAULTS.each do |opt_name, default|
          _o.send("#{opt_name}=", options.fetch(opt_name, default))
        end
        _o.watch     = options[:watch] || !Gon.watch.all_variables.empty?
        _o.tag       = _o.need_tag
        _o.cameled   = _o.camel_case

        _o
      end

      def formatted_data(_o)
        script = _o.amd ? 'var gon={};' : ''

        script << gon_variables(_o.global_root).
                    map { |key, val| render_variable(_o, key, val) }.join
        script << (render_watch(_o) || '')

        script
      end

      def render_variable(_o, key, value)
        js_key = _o.cameled ? key.to_s.camelize(:lower) : key.to_s
        if _o.amd
          "gon['#{js_key}']=#{to_json(value, _o.camel_depth)};"
        else
          "#{_o.namespace}.#{js_key}=#{to_json(value, _o.camel_depth)};"
        end
      end

      def render_watch(_o)
        if _o.watch and Gon::Watch.all_variables.present?
          if _o.amd
            Gon.watch.render_amd
          else
            Gon.watch.render
          end
        end
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

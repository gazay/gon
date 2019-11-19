require 'ostruct'

class Gon
  module Base
    VALID_OPTION_DEFAULTS = {
      namespace: 'gon',
      camel_case: false,
      camel_depth: 1,
      watch: false,
      need_tag: true,
      type: false,
      cdata: true,
      global_root: 'global',
      namespace_check: false,
      amd: false,
      nonce: nil
    }

    class << self
      def render_data(options = {})
        opts = define_options(options)

        script = formatted_data(opts)
        script = Gon::Escaper.escape_unicode(script)
        script = Gon::Escaper.javascript_tag(script, opts.type, opts.cdata, opts.nonce) if opts.need_tag

        script.html_safe
      end

      private

      def define_options(options)
        opts = OpenStruct.new

        VALID_OPTION_DEFAULTS.each do |opt_name, default|
          opts.send("#{opt_name}=", options.fetch(opt_name, default))
        end
        opts.watch   = options[:watch] || !Gon.watch.all_variables.empty?
        opts.cameled = opts.camel_case

        opts
      end

      def formatted_data(opts)
        script = ''
        before, after = render_wrap(opts)
        script << before

        script << gon_variables(opts.global_root)
                  .map { |key, val| render_variable(opts, key, val) }.join
        script << (render_watch(opts) || '')

        script << after
        script
      end

      def render_wrap(opts)
        if opts.amd
          ["define('#{opts.namespace}',[],function(){var gon={};", 'return gon;});']
        else
          before = \
            if opts.namespace_check
              "window.#{opts.namespace}=window.#{opts.namespace}||{};"
            else
              "window.#{opts.namespace}={};"
            end
          [before, '']
        end
      end

      def render_variable(opts, key, value)
        js_key = convert_key(key, opts.cameled)
        if opts.amd
          "gon['#{js_key}']=#{to_json(value, opts.camel_depth)};"
        else
          "#{opts.namespace}.#{js_key}=#{to_json(value, opts.camel_depth)};"
        end
      end

      def render_watch(opts)
        if opts.watch && Gon::Watch.all_variables.present?
          if opts.amd
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
          Hash[value.map do |k, v|
            [convert_key(k, true), convert_hash_keys(v, current_depth + 1, max_depth)]
          end]
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

      def convert_key(key, camelize)
        cache = RequestStore.store[:gon_keys_cache] ||= {}
        cache["#{key}_#{camelize}"] ||= camelize ? key.to_s.camelize(:lower) : key.to_s
      end
    end
  end
end

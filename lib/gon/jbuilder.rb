class Gon
  module Jbuilder
    class << self

      def handler(args, global = false)
        options = parse_options_from args
        if global && !options[:template]
          raise 'You should provide :template when use rabl with global variables'
        end
        controller = Gon::Base.get_controller(options)
        @_controller_name = global ? '' : controller.controller_path

        include_helpers

        data = parse_jbuilder \
          Gon::Base.get_template_path(options, 'jbuilder'),
          controller,
          options[:locals]

        [data, options]
      end

      private

      def include_helpers
        unless self.class.include? ::ActionView::Helpers
          self.class.send(:include, ::ActionView::Helpers)
        end
      end

      def parse_options_from(args)
        if old_api? args
          text =  "[DEPRECATION] view_path argument is now optional. "
          text << "If you need to specify it, "
          text << "please use gon.rabl(:template => 'path')"
          warn text

          args.extract_options!.merge(:template => args[0])
        elsif new_api? args
          args.first
        else
          {}
        end
      end

      def old_api?(args)
        args.first.is_a? String
      end

      def new_api?(args)
        args.first.is_a? Hash
      end

      def parse_jbuilder(jbuilder_path, controller, locals)
        controller.instance_variables.each do |name|
          self.instance_variable_set \
            name,
            controller.instance_variable_get(name)
        end
        controller._helper_methods.each do |meth|
          self.class.class_eval <<-ruby_eval, __FILE__, __LINE__ + 1
              def #{meth}(*args, &blk)                               # def current_user(*args, &blk)
                __controller.send(%(#{meth}), *args, &blk)             #   controller.send(:current_user, *args, &blk)
              end                                                    # end
            ruby_eval
        end
        locals ||= {}
        locals['__controller'] = controller
        locals.each do |name, value|
          self.class.class_eval do
            define_method "#{name}" do
              return value
            end
          end
        end
        lines = find_partials File.readlines(jbuilder_path)
        source = lines.join('')

        output = parse_source source, controller
      end

      def parse_source(source, controller)
        output = ::JbuilderTemplate.encode(controller) do |json|
          eval source
        end
        JSON.parse(output)
      end

      def parse_partial(partial_line)
        path = partial_line.match(/['"]([^'"]*)['"]/)[1]
        path = parse_path path
        options_hash = partial_line.match(/,(.*)/)[1]

        set_options_from_hash(options_hash) if options_hash.present?

        find_partials File.readlines(path)
      end

      def set_options_from_hash(options_hash)
        options = eval "{#{options_hash}}"
        options.each do |name, val|
          self.instance_variable_set("@#{name.to_s}", val)
          eval "def #{name}; self.instance_variable_get('@' + '#{name.to_s}'); end"
        end
      end

      def parse_path(path)
        return path if File.exists?(path)
        if (splitted = path.split('/')).blank?
            raise 'Something wrong with partial path in your jbuilder templates'
        elsif splitted.size == 1
            splitted.shift(@_controller_name)
        end
        construct_path(splitted)
      end

      def construct_path(args)
        last_arg = args.pop
        tmp_path = 'app/views/' + args.join('/')
        path = path_with_ext(tmp_path + "/_#{last_arg}")
        path || path_with_ext(tmp_path + "/#{last_arg}")
      end

      def path_with_ext(path)
        return path if File.exists?(path)
        return "#{path}.jbuilder" if File.exists?("#{path}.jbuilder")
        return "#{path}.json.jbuilder" if File.exists?("#{path}.json.jbuilder")
      end

      def find_partials(lines = [])
        lines.map do |line|
          if line =~ /partial!/
            parse_partial line
          else
            line
          end
        end.flatten
      end

    end
  end
end

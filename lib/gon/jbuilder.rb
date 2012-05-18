module Gon
  module Jbuilder
    class << self

      def handler(args, global = false)
        options = parse_options_from args
        if global && !options[:template]
          raise 'You should provide :template when use rabl with global variables'
        end

        include_helpers

        data = parse_jbuilder \
          Gon::Base.get_template_path(options,'jbuilder'),
          Gon::Base.get_controller(options)

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

      def parse_jbuilder(jbuilder_path, controller)
        controller.instance_variables.each do |name|
          self.instance_variable_set \
            name,
            controller.instance_variable_get(name)
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
        options_hash = partial_line.match(/,(.*)/)[1]
        if options_hash.present?
          options = eval '{' + options_hash + '}'
          options.each do |name, val|
            self.instance_variable_set('@' + name.to_s, val)
            eval "def #{name}; self.instance_variable_get('@' + '#{name.to_s}'); end"
          end
        end
        find_partials File.readlines(path)
      end

      def find_partials(lines = [])
        lines.map do |line|
          if line =~ /partial!/
            parse_partial(line)
          else
            line
          end
        end.flatten
      end

    end
  end
end

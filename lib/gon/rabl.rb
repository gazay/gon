require 'action_view'
require 'rabl'

class Gon
  module Rabl
    class << self

      def handler(args, global = false)
        options = parse_options_from args, global
        if global && !options[:template]
          raise 'You should provide :template when use rabl with global variables'
        end

        include_helpers

        data = parse_rabl \
          Gon::Base.get_template_path(options, 'rabl'),
          Gon::Base.get_controller(options)

        [data, options]
      end

      private

      def parse_rabl(rabl_path, controller)
        source = File.read(rabl_path)
        rabl_engine = ::Rabl::Engine.new(source, :format => 'json')
        output = rabl_engine.render(controller, {})
        JSON.parse(output)
      end

      def parse_options_from(args, global)
        if old_api? args
          unless global
            text =  "[DEPRECATION] view_path argument is now optional. "
            text << "If you need to specify it, "
            text << "please use gon.rabl(:template => 'path')"
            warn text
          end

          args.extract_options!.merge(:template => args[0])
        elsif new_api? args
          args.first
        else
          {}
        end
      end

      def include_helpers
        unless ::Rabl::Engine.include? ::ActionView::Helpers
          ::Rabl::Engine.send(:include, ::ActionView::Helpers)
        end
      end

      def old_api?(args)
        args.first.is_a? String
      end

      def new_api?(args)
        args.first.is_a? Hash
      end

    end
  end
end

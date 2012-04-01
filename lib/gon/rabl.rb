require 'rabl'

module Gon
  module Rabl
    class << self

      def handler(args)
        options = parse_options_from args

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

    end
  end
end

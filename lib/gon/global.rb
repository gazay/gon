module Gon
  module Global
    class << self

      def all_variables
        @global_vars || {}
      end

      def method_missing(method, *args, &block)
        @global_vars ||= {}
        if ( method.to_s =~ /=$/ )
          if public_method_name? method
            raise "You can't use Gon public methods for storing data"
          end

          @global_vars[method.to_s.delete('=')] = args[0]
        else
          @global_vars[method.to_s]
        end
      end

      def rabl(*args)
        data, options = Gon::Rabl.handler(args, true)

        store_builder_data 'rabl', data, options
      end

      def jbuilder(*args)
        data, options = Gon::Jbuilder.handler(args, true)

        store_builder_data 'jbuilder', data, options
      end

      def clear
        @global_vars = {}
      end

      def inspect
        'Gon'
      end

      private

      def store_builder_data(builder, data, options)
        if options[:as]
          @global_vars[options[:as].to_s] = data
        elsif data.is_a? Hash
          data.each do |key, value|
            @global_vars[key] = value
          end
        else
          @global_vars[builder] = data
        end
      end

      def public_method_name?(method)
        public_methods.include?(
          if RUBY_VERSION > '1.9'
            method.to_s[0..-2].to_sym
          else
            method.to_s[0..-2]
          end
        )
      end

    end
  end
end

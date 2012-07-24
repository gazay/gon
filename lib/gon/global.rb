class Gon
  class Global < Gon
    class << self

      def all_variables
        @global_vars || {}
      end

      def clear
        @global_vars = {}
      end

      def inspect
        'Gon::Global'
      end

      def rabl(*args)
        unless Gon.constants.include?(:Rabl)
          raise "Possible wrong require order problem - try to add `gem 'rabl'` before `gem 'gon'` in your Gemfile"
        end
        data, options = Gon::Rabl.handler(args, true)

        store_builder_data 'rabl', data, options
      end

      def jbuilder(*args)
        unless Gon.constants.include?(:Jbuilder)
          raise "Possible wrong require order problem - try to add `gem 'jbuilder'` before `gem 'gon'` in your Gemfile"
        end
        data, options = Gon::Jbuilder.handler(args, true)

        store_builder_data 'jbuilder', data, options
      end

      private

      def get_variable(name)
        @global_vars ||= {}
        @global_vars[name]
      end

      def set_variable(name, value)
        @global_vars ||= {}
        @global_vars[name] = value
      end

    end
  end
end

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

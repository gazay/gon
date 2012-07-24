class Gon
  module Request
    class << self

      def env
        @request_env if defined? @request_env
      end

      def env=(environment)
        @request_env = environment
        @request_env['gon'] ||= {}
      end

      def id
        @request_id if defined? @request_id
      end

      def id=(request_id)
        @request_id = request_id
      end

      def gon
        env['gon'] if env
      end

      def clear
        env && (env['gon'] = {})
      end

    end
  end
end

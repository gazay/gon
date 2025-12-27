# frozen_string_literal: true

begin
  require 'active_support/current_attributes'
rescue LoadError
  begin
    require 'request_store'
  rescue LoadError => e
    message = "#{e.message}\n" \
              "If you are using RequestStore, please add `gem 'request_store'` to your Gemfile."
    raise LoadError, message
  end
end

class Gon
  if defined?(ActiveSupport::CurrentAttributes)
    class Current < ActiveSupport::CurrentAttributes
      attribute :gon
      attribute :gon_keys_cache
    end
  else
    class Current
      def self.gon
        RequestStore.store[:gon]
      end

      def self.gon=(value)
        RequestStore.store[:gon] = value
      end

      def self.gon_keys_cache
        RequestStore.store[:gon_keys_cache]
      end

      def self.gon_keys_cache=(value)
        RequestStore.store[:gon_keys_cache] = value
      end
    end
  end

  private_constant :Current
end

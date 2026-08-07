# frozen_string_literal: true

class Gon
  module SpecHelper
    module Rails
      extend ActiveSupport::Concern

      module ClassMethods
        module GonSession
          def process(*args, **kwargs)
            @gon_request = nil

            # preload threadlocal & store controller instance
            if gon_controller.is_a? ActionController::Base
              gon_controller.gon
              @gon_request = Gon.send(:current_gon)
              Gon.send(:current_gon).env[Gon::EnvFinder::ENV_CONTROLLER_KEY] =
               gon_controller
            end

            if ActionPack::VERSION::MAJOR < 4
              super(*args.first(5))
            else
              super(*args, **kwargs)
            end
          end

          def gon_variables
            @gon_request ? @gon_request.gon : {}
          end

          private

          def gon_controller
            respond_to?(:controller) ? controller : @controller
          end
        end

        def new(*)
          super.extend(GonSession)
        end
      end
    end
  end
end

if ENV['RAILS_ENV'] == 'test' && defined?(ActionController::TestCase::Behavior)
  ActionController::TestCase::Behavior.send :include, Gon::SpecHelper::Rails
end

# frozen_string_literal: true

require 'action_controller'
require 'action_controller/test_case'

describe Gon::SpecHelper::Rails do
  let(:current) { Gon.const_get(:Current) }
  let(:routes) do
    ActionDispatch::Routing::RouteSet.new.tap do |routes|
      routes.draw do
        get 'show' => 'anonymous#show'
        get 'show' => 'anonymous_controller#show'
      end
    end
  end
  let(:controller_class) do
    routes = self.routes

    Class.new(ActionController::Base) do
      include routes.url_helpers

      def show
        gon.foo = 'bar'
        render(ActionPack::VERSION::MAJOR >= 4 ? { plain: 'hello' } : { text: 'hello' })
      end
    end
  end
  let(:test_case_class) do
    routes = self.routes
    controller_class = self.controller_class

    Class.new(ActionController::TestCase) do
      include Gon::SpecHelper::Rails

      tests controller_class

      define_method(:setup) do
        super()
        @routes = routes
      end

      def test_show; end
    end
  end
  let(:test_case) { test_case_class.new(:test_show) }

  before do
    current.gon = nil
  end

  after do
    begin
      test_case.before_teardown if test_case && test_case.respond_to?(:before_teardown)
      test_case.teardown if test_case
    ensure
      current.gon = Gon::Request.new({})
    end
  end

  def setup_test_case
    test_case.before_setup if test_case.respond_to?(:before_setup)
    test_case.setup
    test_case.send(:setup_controller_request_and_response) if test_case.instance_variable_get(:@controller).nil?
    test_case.after_setup if test_case.respond_to?(:after_setup)
  end

  describe '#gon_variables' do
    it 'returns an empty hash before a request is processed' do
      setup_test_case

      expect(test_case.gon_variables).to eq({})
    end

    it 'returns gon variables assigned in an ActionController::TestCase request' do
      setup_test_case

      test_case.get(:show)

      expect(test_case.response.status).to eq(200)
      expect(test_case.response.body).to eq('hello')
      expect(test_case.gon_variables).to eq({ 'foo' => 'bar' })
    end

    it 'returns gon variables after the current attributes are reset' do
      setup_test_case

      test_case.get(:show)
      current.gon = nil

      expect(Gon.all_variables).to eq({})
      expect(test_case.gon_variables).to eq({ 'foo' => 'bar' })
    end
  end
end

require 'spec_helper'

describe Gon::Watch do

  let(:controller) { ActionController::Base.new }
  let(:request) { ActionDispatch::Request.new({}) }

  before :each do
    controller.request = request
    controller.params = {}
    env = {}
    env['ORIGINAL_FULLPATH'] = '/foo'
    env['REQUEST_METHOD'] = 'GET'

    Gon::Watch.clear
    Gon.send(:current_gon).instance_variable_set(:@request_env, env)
    Gon.send(:current_gon).env['action_controller.instance'] = controller
    Gon.clear
  end

  it 'should add variables to Gon#all_variables hash' do
    Gon.a = 1
    Gon.watch.b = 2
    expect(Gon.all_variables).to eq({ 'a' => 1, 'b' => 2 })
  end

  describe '#all_variables' do

    it 'should generate array with current request url, method type and variable names' do
      Gon.watch.a = 1
      expect(Gon.watch.all_variables).to eq({ 'a' => { 'url' => '/foo', 'method' => 'GET', 'name' => 'a' } })
    end

  end

  describe '#render' do

    it 'should render function with variables in gon namespace' do
      Gon.watch.a = 1
      expect(Gon.watch.render).to match(/gon\.watch\s=/)
      expect(Gon.watch.render).to match(/gon\.watchedVariables/)
    end

  end

  it 'should return value of variable if called right request' do
    env = Gon.send(:current_gon).instance_variable_get(:@request_env)
    env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    request = ActionDispatch::Request.new env
    controller.request = request
    params = {}
    params[:gon_return_variable] = true
    params[:gon_watched_variable] = 'a'
    controller.params = params
    Gon.send(:current_gon).env['action_controller.instance'] = controller

    expect(controller).to receive('render').with(:json => 1)

    Gon.watch.a = 1
  end

end

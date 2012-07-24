require 'gon'

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
    Gon::Request.instance_variable_set(:@request_env, env)
    Gon::Request.env['action_controller.instance'] = controller
    Gon.clear
  end

  it 'should add variables to Gon#all_variables hash' do
    Gon.a = 1
    Gon.watch.b = 2
    Gon.all_variables.should == { 'a' => 1, 'b' => 2 }
  end

  describe '#all_variables' do

    it 'should generate array with current request url, method type and variable names' do
      Gon.watch.a = 1
      Gon.watch.all_variables.should == { 'a' => { 'url' => '/foo', 'method' => 'GET', 'name' => 'a' } }
    end

  end

  describe '#render' do

    it 'should render function with variables in gon namespace' do
      Gon.watch.a = 1
      Gon.watch.render.should =~ /gon\.watch\s=/
      Gon.watch.render.should =~ /gon\.watchedVariables/
    end

  end

  it 'should return value of variable if called right request' do
    env = Gon::Request.instance_variable_get :@request_env
    env["HTTP_X_REQUESTED_WITH"] = "XMLHttpRequest"
    request = ActionDispatch::Request.new env
    controller.request = request
    params = {}
    params[:gon_return_variable] = true
    params[:gon_watched_variable] = 'a'
    controller.params = params
    Gon::Request.env['action_controller.instance'] = controller

    controller.should_receive('render').with(:text => '1')

    Gon.watch.a = 1
  end

end

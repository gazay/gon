# gon_spec_rb
require 'gon'

describe Gon, '#all_variables' do 
  before(:each) do 
    Gon.request_env = {}
  end

  it 'returns all variables in hash' do
    Gon.a = 1
    Gon.b = 2
    Gon.c = Gon.a + Gon.b
    Gon.c.should == 3
    Gon.all_variables.should == {'a' => 1, 'b' => 2, 'c' => 3}
  end

  it 'supports all data types' do
    Gon.clear
    Gon.int = 1
    Gon.float = 1.1
    Gon.string = 'string'
    Gon.array = [ 1, 'string' ]
    Gon.hash_var = { :a => 1, :b => '2'}
    Gon.hash_w_array = { :a => [ 2, 3 ] }
    Gon.klass = Hash
  end

  it 'output as js correct' do
    Gon.clear
    Gon.int = 1
    ActionView::Base.instance_methods.map(&:to_s).include?('include_gon').should == true
    base = ActionView::Base.new
    base.include_gon.should == "<script>window.gon = {};" +
                                 "gon.int=1;" +
                               "</script>"
  end

  it 'returns exception if try to set public method as variable' do
    Gon.clear
    lambda { Gon.all_variables = 123 }.should raise_error
  end

  it 'render json from rabl template' do
    Gon.clear
    controller = ActionController::Base.new
    objects = [1,2]
    controller.instance_variable_set('@objects', objects)
    Gon.rabl 'spec/test_data/sample.rabl', :controller => controller
    Gon.objects.length.should == 2
  end

  def request
    @request ||= double 'request', :env => {}
  end
end

# gon_spec_rb
require 'gon'

describe Gon, '#all_variables' do 
  it 'returns all variables in hash' do
    Gon.a = 1
    Gon.b = 2
    Gon.c = Gon.a + Gon.b
    Gon.c.should == 3
    Gon.all_variables.should == {:a => 1, :b => 2, :c => 3}
  end
  
  it 'supports all data types' do
    Gon.clear
    Gon.int = 1
    Gon.float = 1.1
    Gon.string = 'string'
    Gon.array = [ 1, 'string' ]
    Gon.hash = { :a => 1, :b => '2'}
    Gon.hash_w_array = { :a => [ 2, 3 ] }
    Gon.klass = OpenStruct.new
    
    ActionView::Base.instance_methods.include?('include_gon').should == true
    base = ActionView::Base.new
    base.include_gon.should == "<script>window.Gon = {};" +
                                 "Gon.klass={\"table\":{}};" +
                                 "Gon.string=\"string\";" +
                                 "Gon.array=[1,\"string\"];" +
                                 "Gon.float=1.1;" +
                                 "Gon.int=1;" +
                                 "Gon.hash={\"a\":1,\"b\":\"2\"};" +
                                 "Gon.hash_w_array={\"a\":[2,3]};" +
                               "</script>"
  end
end
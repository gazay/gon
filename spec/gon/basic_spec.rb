require 'gon'

describe Gon do

  before(:each) do
    Gon::Request.env = {}
  end

  describe '#all_variables' do

    it 'returns all variables in hash' do
      Gon.a = 1
      Gon.b = 2
      Gon.c = Gon.a + Gon.b
      Gon.c.should == 3
      Gon.all_variables.should == {'a' => 1, 'b' => 2, 'c' => 3}
    end

    it 'supports all data types' do
      Gon.clear
      Gon.int           = 1
      Gon.float         = 1.1
      Gon.string        = 'string'
      Gon.array         = [ 1, 'string' ]
      Gon.hash_var      = { :a => 1, :b => '2'}
      Gon.hash_w_array  = { :a => [ 2, 3 ] }
      Gon.klass         = Hash
    end

  end

  describe '#include_gon' do

    before(:each) do
      Gon.clear
      Gon::Request.
        instance_variable_set(:@request_id, request.object_id)
      ActionView::Base.
        instance_methods.
        map(&:to_s).
        include?('include_gon').should == true
      @base = ActionView::Base.new
      @base.request = request
    end

    it 'outputs correct js with an integer' do
      Gon.int = 1
      @base.include_gon.should == '<script>window.gon = {};' +
                                    'gon.int=1;' +
                                  '</script>'
    end

    it 'outputs correct js with a string' do
      Gon.str = %q(a'b"c)
      @base.include_gon.should == '<script>window.gon = {};' +
                                    %q(gon.str="a'b\"c";) +
                                  '</script>'
    end

    it 'outputs correct js with a script string' do
      Gon.str = %q(</script><script>alert('!')</script>)
      @base.include_gon.should == '<script>window.gon = {};' +
                                    %q(gon.str="\\u003C/script><script>alert('!')\\u003C/script>";) +
                                  '</script>'
    end

    it 'outputs correct js with an integer, camel-case and namespace' do
      Gon.int_cased = 1
      @base.include_gon(camel_case: true, namespace: 'camel_cased').should == \
                                  '<script>window.camel_cased = {};' +
                                    'camel_cased.intCased=1;' +
                                  '</script>'
    end

    it 'outputs correct js with an integer and without tag' do
      Gon.int = 1
      @base.include_gon(need_tag: false).should == \
                                  'window.gon = {};' +
                                  'gon.int=1;'
    end

    it 'outputs correct js without variables, without tag and gon init if before there was data' do
      Gon::Request.
        instance_variable_set(:@request_id, 123)
      Gon::Request.instance_variable_set(:@request_env, { 'gon' => { :a => 1 } })
      @base.include_gon(need_tag: false, init: true).should == \
                                  'window.gon = {};'
    end

    it 'outputs correct js without variables, without tag and gon init' do
      @base.include_gon(need_tag: false, init: true).should == \
                                  'window.gon = {};'
    end

    it 'outputs correct js without variables, without tag, gon init and an integer' do
      Gon.int = 1
      @base.include_gon(need_tag: false, init: true).should == \
                                  'window.gon = {};' +
                                  'gon.int=1;'
    end

    it 'outputs correct js with type text/javascript' do
      @base.include_gon(need_type: true, init: true).should == \
                                  '<script type="text/javascript">' +
                                    'window.gon = {};'\
                                  '</script>'
    end

  end

  it 'returns exception if try to set public method as variable' do
    Gon.clear
    lambda { Gon.all_variables = 123 }.should raise_error
    lambda { Gon.rabl = 123 }.should raise_error
  end

  def request
    @request ||= double 'request', :env => {}
  end

end

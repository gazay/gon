require 'spec_helper'

describe Gon do

  before(:each) do
  end

  describe '#all_variables' do

    it 'returns all variables in hash' do
      Gon.a = 1
      Gon.b = 2
      Gon.c = Gon.a + Gon.b
      expect(Gon.c).to eq(3)
      expect(Gon.all_variables).to eq({ 'a' => 1, 'b' => 2, 'c' => 3 })
    end

    it 'supports all data types' do
      Gon.clear
      Gon.int          = 1
      Gon.float        = 1.1
      Gon.string       = 'string'
      Gon.array        = [1, 'string']
      Gon.hash_var     = { :a => 1, :b => '2' }
      Gon.hash_w_array = { :a => [2, 3] }
      Gon.klass        = Hash
    end

    it 'can be filled with dynamic named variables' do
      Gon.clear

      check = {}
      3.times do |i|
        Gon.set_variable("variable#{i}", i)
        check["variable#{i}"] = i
      end

      expect(Gon.all_variables).to eq(check)
    end

    it 'can set and get variable with dynamic name' do
      Gon.clear
      var_name = "variable#{rand}"

      Gon.set_variable(var_name, 1)
      expect(Gon.get_variable(var_name)).to eq(1)
    end

    it 'can be support new push syntax' do
      Gon.clear

      Gon.push({ :int => 1, :string => 'string' })
      expect(Gon.all_variables).to eq({ 'int' => 1, 'string' => 'string' })
    end

    it 'push with wrong object' do
      expect {
        Gon.clear
        Gon.push(String.new('string object'))
      }.to raise_error('Object must have each_pair method')
    end

  end

  describe '#include_gon' do

    before(:each) do
      Gon.clear
      Gon::Request.
        instance_variable_set(:@request_id, request.object_id)
      expect(ActionView::Base.
        instance_methods.
        map(&:to_s).
        include?('include_gon')).to eq(true)
      @base = ActionView::Base.new
      @base.request = request
    end

    it 'outputs correct js with an integer' do
      Gon.int = 1
      expect(@base.include_gon).to eq('<script type="text/javascript">' +
                                    "\n//<![CDATA[\n" +
                                    'window.gon={};' +
                                    'gon.int=1;' +
                                    "\n//]]>\n" +
                                  '</script>')
    end

    it 'outputs correct js with a string' do
      Gon.str = %q(a'b"c)
      expect(@base.include_gon).to eq('<script type="text/javascript">' +
                                    "\n//<![CDATA[\n" +
                                    'window.gon={};' +
                                    %q(gon.str="a'b\"c";) +
                                    "\n//]]>\n" +
                                  '</script>')
    end

    it 'outputs correct js with a script string' do
      Gon.str = %q(</script><script>alert('!')</script>)
      expect(@base.include_gon).to eq('<script type="text/javascript">' +
                                    "\n//<![CDATA[\n" +
                                    'window.gon={};' +
                                    %q(gon.str="\u003C/script><script>alert('!')\u003C/script>";) +
                                    "\n//]]>\n" +
                                  '</script>')
    end

    it 'outputs correct js with an integer, camel-case and namespace' do
      Gon.int_cased = 1
      expect(@base.include_gon(camel_case: true, namespace: 'camel_cased')).to eq( \
                                  '<script type="text/javascript">' +
                                    "\n//<![CDATA[\n" +
                                    'window.camel_cased={};' +
                                    'camel_cased.intCased=1;' +
                                    "\n//]]>\n" +
                                  '</script>'
      )
    end

    it 'outputs correct js with camel_depth = :recursive' do
      Gon.test_hash = { test_depth_one: { test_depth_two: 1 } }
      expect(@base.include_gon(camel_case: true, camel_depth: :recursive)).to eq( \
                                  '<script type="text/javascript">' +
                                    "\n//<![CDATA[\n" +
                                    'window.gon={};' +
                                    'gon.testHash={"testDepthOne":{"testDepthTwo":1}};' +
                                    "\n//]]>\n" +
                                  '</script>'
      )
    end

    it 'outputs correct js with camel_depth = 2' do
      Gon.test_hash = { test_depth_one: { test_depth_two: 1 } }
      expect(@base.include_gon(camel_case: true, camel_depth: 2)).to eq( \
                                  '<script type="text/javascript">' +
                                    "\n//<![CDATA[\n" +
                                    'window.gon={};' +
                                    'gon.testHash={"testDepthOne":{"test_depth_two":1}};' +
                                    "\n//]]>\n" +
                                  '</script>'
      )
    end

    it 'outputs correct js with an integer and without tag' do
      Gon.int = 1
      expect(@base.include_gon(need_tag: false)).to eq( \
                                  'window.gon={};' +
                                  'gon.int=1;'
      )
    end

    it 'outputs correct js without variables, without tag and gon init if before there was data' do
      Gon::Request.
        instance_variable_set(:@request_id, 123)
      Gon::Request.instance_variable_set(:@request_env, { 'gon' => { :a => 1 } })
      expect(@base.include_gon(need_tag: false, init: true)).to eq( \
                                  'window.gon={};'
      )
    end

    it 'outputs correct js without variables, without tag and gon init' do
      expect(@base.include_gon(need_tag: false, init: true)).to eq( \
                                  'window.gon={};'
      )
    end

    it 'outputs correct js without variables, without tag, gon init and an integer' do
      Gon.int = 1
      expect(@base.include_gon(need_tag: false, init: true)).to eq( \
                                  'window.gon={};' +
                                  'gon.int=1;'
      )
    end

    it 'outputs correct js without cdata, without type, gon init and an integer' do
      Gon.int = 1
      expect(@base.include_gon(cdata: false, type: false)).to eq( \
                                  '<script>' +
                                    "\n" +
                                    'window.gon={};' +
                                    'gon.int=1;' +
                                    "\n" +
                                  '</script>'
      )
    end

    it 'outputs correct js with type text/javascript' do
      expect(@base.include_gon(need_type: true, init: true)).to eq( \
                                  '<script type="text/javascript">' +
                                    "\n//<![CDATA[\n" +
                                    'window.gon={};'\
                                    "\n//]]>\n" +
                                  '</script>'
      )
    end

  end

  it 'returns exception if try to set public method as variable' do
    Gon.clear
    expect { Gon.all_variables = 123 }.to raise_error
    expect { Gon.rabl = 123 }.to raise_error
  end

  describe '#check_for_rabl_and_jbuilder' do

    let(:controller) { ActionController::Base.new }

    it 'should be able to handle ruby 1.8.7 style constants array (strings)' do
      constants_as_strings = Gon.constants.map(&:to_s)
      allow(Gon).to receive(:constants) { constants_as_strings }
      expect { Gon.rabl 'spec/test_data/sample.rabl', :controller => controller }.not_to raise_error
      expect { Gon.jbuilder 'spec/test_data/sample.json.jbuilder', :controller => controller }.not_to raise_error
    end

    it 'should be able to handle ruby 1.9+ style constants array (symbols)' do
      constants_as_symbols = Gon.constants.map(&:to_sym)
      allow(Gon).to receive(:constants) { constants_as_symbols }
      expect { Gon.rabl 'spec/test_data/sample.rabl', :controller => controller }.not_to raise_error
      expect { Gon.jbuilder 'spec/test_data/sample.json.jbuilder', :controller => controller }.not_to raise_error
    end
  end

  def request
    @request ||= double 'request', :env => {}
  end

end

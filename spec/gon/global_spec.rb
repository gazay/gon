# frozen_string_literal: true

describe Gon::Global do
  before { Gon::Global.clear }

  describe '#all_variables' do
    it 'returns all variables in hash' do
      Gon.global.a = 1
      Gon.global.b = 2
      Gon.global.c = Gon.global.a + Gon.global.b
      expect(Gon.global.c).to eq(3)
      expect(Gon.global.all_variables).to eq({ 'a' => 1, 'b' => 2, 'c' => 3 })
    end

    it 'supports all data types' do
      Gon.global.int          = 1
      Gon.global.float        = 1.1
      Gon.global.string       = 'string'
      Gon.global.symbol       = :symbol
      Gon.global.array        = [1, 'string']
      Gon.global.hash_var     = { :a => 1, :b => '2' }
      Gon.global.hash_w_array = { :a => [2, 3] }
      Gon.global.klass        = Hash
    end
  end

  it 'returns exception if try to set public method as variable' do
    expect { Gon.global.all_variables = 123 }.to raise_error(RuntimeError)
    expect { Gon.global.rabl = 123 }.to raise_error(RuntimeError)
  end

  context 'with jbuilder and rabl' do
    before do
      controller.instance_variable_set('@objects', objects)
    end

    let(:controller) { ActionController::Base.new }
    let(:objects) { [1, 2] }

    it 'works fine with rabl' do
      Gon.global.rabl :template => 'spec/test_data/sample.rabl', :controller => controller
      expect(Gon.global.objects.length).to eq(2)
    end

    it 'works fine with jbuilder' do
      allow(Rails).to receive_message_chain(:application, :routes, :url_helpers, :instance_methods) { [] }
      Gon.global.jbuilder :template => 'spec/test_data/sample.json.jbuilder', :controller => controller
      expect(Gon.global.objects.length).to eq(2)
    end

    it 'should throw exception, if use rabl or jbuilder without :template' do
      expect { Gon.global.rabl }.to raise_error(RuntimeError)
      expect { Gon.global.jbuilder }.to raise_error(RuntimeError)
    end
  end
end

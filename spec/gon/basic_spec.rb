# frozen_string_literal: true

describe Gon do
  before do
    RequestStore.store[:gon] = Gon::Request.new({})
    Gon.clear
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
      Gon.int          = 1
      Gon.float        = 1.1
      Gon.string       = 'string'
      Gon.symbol       = :symbol
      Gon.array        = [1, 'string']
      Gon.hash_var     = { :a => 1, :b => '2' }
      Gon.hash_w_array = { :a => [2, 3] }
      Gon.klass        = Hash
    end

    it 'can be filled with dynamic named variables' do
      check = {}
      3.times do |i|
        Gon.set_variable("variable#{i}", i)
        check["variable#{i}"] = i
      end

      expect(Gon.all_variables).to eq(check)
    end

    it 'can set and get variable with dynamic name' do
      var_name = "variable#{rand}"

      Gon.set_variable(var_name, 1)
      expect(Gon.get_variable(var_name)).to eq(1)
    end

    it 'can be support new push syntax' do
      Gon.push({ :int => 1, :string => 'string' })
      expect(Gon.all_variables).to eq({ 'int' => 1, 'string' => 'string' })
    end

    it 'push with wrong object' do
      expect {
        Gon.push(String.new('string object'))
      }.to raise_error('Object must have each_pair method')
    end

    describe "#merge_variable" do
      it 'deep merges the same key' do
        Gon.merge_variable(:foo, { bar: { tar: 12 }, car: 23 })
        Gon.merge_variable(:foo, { bar: { dar: 21 }, car: 12 })
        expect(Gon.get_variable(:foo)).to  eq(bar: { tar: 12, dar: 21 }, car: 12)
      end

      it 'merges on push with a flag' do
        Gon.push(foo: { bar: 1 })
        Gon.push({ foo: { tar: 1 } }, :merge)
        expect(Gon.get_variable("foo")).to eq(bar: 1, tar: 1)
      end

      context 'overrides key' do
        specify "the previous value wasn't hash" do
          Gon.merge_variable(:foo, 2)
          Gon.merge_variable(:foo, { a: 1 })
          expect(Gon.get_variable(:foo)).to eq(a: 1)
        end

        specify "the new value isn't a hash" do
          Gon.merge_variable(:foo, { a: 1 })
          Gon.merge_variable(:foo, 2)
          expect(Gon.get_variable(:foo)).to eq(2)
        end
      end
    end
  end

  it 'returns exception if try to set public method as variable' do
    expect { Gon.all_variables = 123 }.to raise_error(RuntimeError)
    expect { Gon.rabl = 123 }.to raise_error(RuntimeError)
  end

  describe '#check_for_rabl_and_jbuilder' do
    let(:controller) { ActionController::Base.new }

    it 'should be able to handle constants array (symbols)' do
      allow(Rails).to receive_message_chain(:application, :routes, :url_helpers, :instance_methods) { [] }
      allow(Gon).to receive(:constants) { Gon.constants }
      expect { Gon.rabl :template => 'spec/test_data/sample.rabl', :controller => controller }.not_to raise_error
      expect { Gon.jbuilder :template => 'spec/test_data/sample.json.jbuilder', :controller => controller }.not_to raise_error
    end
  end
end

# frozen_string_literal: true

describe Gon::JsonDumper do
  it 'generates JSON with script-unsafe characters escaped' do
    object = {
      string: "<script>&\u2028\u2029",
      number: 1,
      boolean: true,
      nothing: nil
    }
    expected = '{"string":"\\u003cscript\\u003e\\u0026\\u2028\\u2029",' \
               '"number":1,"boolean":true,"nothing":null}'

    expect(described_class.dump(object)).to eq(expected)
  end

  context 'with the available multi_json namespace' do
    let(:backend) { defined?(MultiJSON) ? MultiJSON : MultiJson }
    let(:script_unsafe_data) { { string: '</script>&' } }
    let(:generation_method) { defined?(MultiJSON) ? :generate : :dump }

    it 'passes Oj options when the selected adapter is Oj and escapes the result' do
      backend.with_adapter(:oj) do
        expect(backend).to receive(generation_method)
          .with(script_unsafe_data, { mode: :compat, escape_mode: :xss_safe, time_format: :ruby })
          .and_call_original

        expect(described_class.dump(script_unsafe_data)).to eq('{"string":"\u003c/script\u003e\u0026"}')
      end
    end

    it 'omits Oj options when Oj is loaded but another adapter is selected' do
      require 'multi_json/adapters/oj'
      backend.with_adapter(:json_gem) do
        expect(backend).to receive(generation_method)
          .with(script_unsafe_data, {})
          .and_call_original

        expect(described_class.dump(script_unsafe_data)).to eq('{"string":"\u003c/script\u003e\u0026"}')
      end
    end

    it 'generates escaped JSON when the Oj adapter constant is not loaded' do
      backend.with_adapter(:json_gem) do
        hide_const("#{backend.name}::Adapters::Oj")
        expect(backend).to receive(generation_method)
          .with(script_unsafe_data, {})
          .and_call_original

        expect(described_class.dump(script_unsafe_data)).to eq('{"string":"\u003c/script\u003e\u0026"}')
      end
    end
  end
end

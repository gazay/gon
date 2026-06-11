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
end

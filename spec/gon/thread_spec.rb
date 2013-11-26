require 'spec_helper'

describe 'threading behaviour' do
  it 'is threadsafe' do
    threads = []
    10.times do
      threads << Thread.new do
        Gon.clear
        Gon.a ||= 1
        Gon.a += 1
        expect(Gon.a).to eq 2
      end
    end
    threads.each(&:join)
    expect(Gon.a).to eq 2
  end
end

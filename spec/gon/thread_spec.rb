require 'spec_helper'

class GonTestWorker
  include Gon::GonHelpers

  def request
    @request ||= ActionDispatch::TestRequest.new
  end

  def env
    request.env
  end

  def execute
    gon.clear
    gon.a ||= 1
    gon.a += 1
  end

  def value
    gon.a
  end
end

describe 'threading behaviour' do
  before do
    Gon.unstub(:current_gon)
  end

  it 'is threadsafe' do
    threads = []
    10.times do
      threads << Thread.new do
        gtw = GonTestWorker.new
        gtw.execute
        expect(gtw.value).to eq 2
      end
    end
    threads.each(&:join)
  end
end

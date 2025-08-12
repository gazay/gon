# frozen_string_literal: true
require 'action_dispatch/testing/test_request'

class GonTestWorker
  include Gon::ControllerHelpers

  def request
    @request ||= ActionDispatch::TestRequest.create
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

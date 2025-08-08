# frozen_string_literal: true

require 'rails/railtie'
require 'rails/version' # jbuilder <= 2.13.0 checks rails version
require 'gon'
require 'jbuilder'

RSpec.configure do |config|
  config.before(:each) do
    RequestStore.store[:gon] = Gon::Request.new({})
    @request = RequestStore.store[:gon]
    allow(Gon).to receive(:current_gon).and_return(@request)
  end
end

def request
  @request ||= double 'request', :env => {}
end

def wrap_script(content, cdata=true)
  script = +"<script>"
  script << "\n//<![CDATA[\n" if cdata
  script << content
  script << "\n//]]>\n" if cdata
  script << '</script>'
end

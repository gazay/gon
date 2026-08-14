# frozen_string_literal: true

begin
  require 'test/unit'
  Test::Unit::AutoRunner.need_auto_run = false
rescue LoadError
end

require 'active_support/all'
Test::Unit::AutoRunner.need_auto_run = false if defined?(Test::Unit::AutoRunner)

require 'rails/railtie'
require 'rails/version' # jbuilder <= 2.13.0 checks rails version
require 'gon'
require 'jbuilder'

RSpec.configure do |_config|
end

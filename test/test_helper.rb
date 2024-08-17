# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "airbased"
require "minitest/autorun"
require "minitest/reporters"

require "webmock/minitest"
WebMock.disable_net_connect!
WebMock.disable!

require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end
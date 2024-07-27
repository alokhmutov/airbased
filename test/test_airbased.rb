# frozen_string_literal: true

require "test_helper"

class TestAirbased < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Airbased::VERSION
  end

  def setup
    # Ensure the api_key and debug are reset before each test
    Airbased.api_key = nil
    Airbased.debug = nil
  end

  def test_api_key_accessor
    Airbased.api_key = "test_api_key"
    assert_equal "test_api_key", Airbased.api_key, "API key should be set correctly"
  end

  def test_debug_accessor
    Airbased.debug = true
    assert_equal true, Airbased.debug, "Debug mode should be set to true"

    Airbased.debug = false
    assert_equal false, Airbased.debug, "Debug mode should be set to false"
  end
end

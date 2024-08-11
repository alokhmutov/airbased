# frozen_string_literal: true

require "test_helper"

class TestAirbased < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Airbased::VERSION
  end

  # TODO: test for silence
  def test_debug_accessor
    Airbased.debug = true
    assert_equal true, Airbased.debug, "Debug mode should be set to true"

    Airbased.debug = false
    assert_equal false, Airbased.debug, "Debug mode should be set to false"
  end
end

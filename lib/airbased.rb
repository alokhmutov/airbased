# frozen_string_literal: true

require_relative "airbased/version"

# Airbased is a module for interfacing with the Airtable API.
module Airbased
  extend self
  attr_accessor :api_key, :debug

  class Error < StandardError; end
end

# frozen_string_literal: true

require_relative "airbased/version"
require_relative "airbased/airtable"
require_relative "airbased/table"
require_relative "airbased/base"
require_relative "airbased/record"

# Airbased is a module for interfacing with the Airtable API.
module Airbased
  extend self
  attr_accessor :api_key, :debug

  class Error < StandardError; end
end

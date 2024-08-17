# frozen_string_literal: true

require "time"

require_relative "airbased/version"
require_relative "airbased/airtable/errors"
require_relative "airbased/airtable/airtable"
require_relative "airbased/base"

require_relative "airbased/table/query"
require_relative "airbased/table/persistence"
require_relative "airbased/table/table"

require_relative "airbased/record/persistence"
require_relative "airbased/record"

# Airbased is a module for interfacing with the Airtable API.
module Airbased
  extend self
  attr_accessor :api_key, :debug

  class Error < StandardError; end
end

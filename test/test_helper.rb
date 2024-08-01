# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "airbased"
require "minitest/autorun"
require 'minitest/reporters'

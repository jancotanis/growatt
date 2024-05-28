# frozen_string_literal: true
require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'minitest/autorun'
require 'minitest/spec'

require 'dotenv'
require 'growatt'

Dotenv.load

TEST_LOGGER = 'test.log'

File.delete(TEST_LOGGER) if File.exist?(TEST_LOGGER)

Growatt.reset
Growatt.configure do |config|
  config.username = ENV['GROWATT_USERNAME']
  config.password = ENV['GROWATT_PASSWORD']
  config.logger = Logger.new(TEST_LOGGER)
end

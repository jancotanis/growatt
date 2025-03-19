# frozen_string_literal: true

require 'wrapi'
require File.expand_path('authorization', __dir__)
require File.expand_path('connection', __dir__)

module Growatt
  # The `API` class is an internal component of the Growatt module.
  # It is responsible for managing API configurations, connections, and authentication.
  #
  # This class should not be accessed directly. Instead, use `Growatt.client` to interact with the API.
  #
  class API
    # Attribute accessors for all valid configuration options.
    #
    # These options are defined in `WrAPI::Configuration::VALID_OPTIONS_KEYS`.
    attr_accessor *WrAPI::Configuration::VALID_OPTIONS_KEYS

    # Initializes a new `Growatt::API` instance.
    #
    # This method copies configuration settings from the Growatt module singleton and allows
    # for optional overrides through the `options` parameter.
    #
    # @param options [Hash] Optional configuration overrides.
    #
    # @example Creating an API instance with custom options:
    #   api = Growatt::API.new(user_agent: "CustomClient/1.0")
    #
    def initialize(options = {})
      options = Growatt.options.merge(options)
      WrAPI::Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    # Retrieves the current API configuration as a hash.
    #
    # @return [Hash] A hash containing the current API configuration.
    #
    # @example Getting the current configuration:
    #   api.config # => { endpoint: "https://server.growatt.com/", user_agent: "Ruby Growatt API client ..." }
    #
    def config
      conf = {}
      WrAPI::Configuration::VALID_OPTIONS_KEYS.each do |key|
        conf[key] = send key
      end
      conf
    end

    # Includes required modules for making API requests, handling authentication,
    # and establishing connections.
    include WrAPI::Connection
    include Connection
    include WrAPI::Request
    include WrAPI::Authentication
    include Authentication
  end
end

# frozen_string_literal: true

require 'wrapi'
require File.expand_path('growatt/client', __dir__)
require File.expand_path('growatt/version', __dir__)
require File.expand_path('growatt/pagination', __dir__)

# The `Growatt` module provides a Ruby client for interacting with the Growatt API.
#
# It extends `WrAPI::Configuration` for managing API settings and `WrAPI::RespondTo`
# for handling API responses dynamically.
#
# The module allows you to create a client instance, configure API endpoints, and manage pagination settings.
#
# @example Creating a Growatt API client:
#   client = Growatt.client(api_key: "your_api_key")
#
module Growatt
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  # Default User-Agent string for API requests.
  DEFAULT_UA = "Ruby Growatt API client #{Growatt::VERSION}".freeze

  # Default API endpoint for Growatt services.
  #
  # Note: `https://openapi.growatt.com/` is an alternative, but it does not work with some accounts.
  DEFAULT_ENDPOINT = 'https://server.growatt.com/'

  # Default pagination class used for handling paginated API responses.
  DEFAULT_PAGINATION = RequestPagination::DataPager

  # Initializes and returns a new `Growatt::Client` instance.
  #
  # @param options [Hash] Configuration options for the client.
  # @option options [String] :user_agent Custom user agent string.
  # @option options [String] :endpoint Custom API endpoint.
  # @option options [Class] :pagination_class Custom pagination class.
  #
  # @return [Growatt::Client] A new API client instance.
  #
  # @example Creating a client with custom options:
  #   client = Growatt.client(user_agent: "MyCustomClient/1.0")
  def self.client(options = {})
    Growatt::Client.new({ 
      user_agent: DEFAULT_UA, 
      endpoint: DEFAULT_ENDPOINT, 
      pagination_class: DEFAULT_PAGINATION 
    }.merge(options))
  end

  # Resets the Growatt configuration to default values.
  #
  # This method restores the API endpoint, user agent, and pagination settings to their default values.
  def self.reset
    super
    self.endpoint   = nil
    self.user_agent = DEFAULT_UA
    self.endpoint   = DEFAULT_ENDPOINT
    self.pagination_class = DEFAULT_PAGINATION
  end
end

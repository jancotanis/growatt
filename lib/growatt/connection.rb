# frozen_string_literal: true

require 'faraday'
require 'faraday-cookie_jar'

module Growatt
  # Handles HTTP connection setup and authentication management.
  #
  # This module establishes a Faraday connection to interact with the Growatt API,
  # ensuring proper authentication via cookies and setting up required headers.
  module Connection
    # Establishes a Faraday connection with appropriate middleware and settings.
    #
    # @return [Faraday::Connection] The configured Faraday connection instance.
    # @raise [ConfigurationError] If the API endpoint is not defined.
    def connection
      raise ConfigurationError, "Option for endpoint is not defined" unless endpoint

      options = setup_options
      @connection ||= Faraday::Connection.new(options) do |connection|
        # Enable cookie-based authentication
        connection.use :cookie_jar

        # Handle HTTP response errors
        connection.use Faraday::Response::RaiseError

        # Set up default Faraday adapter
        connection.adapter Faraday.default_adapter

        # Configure authentication and request headers
        setup_authorization(connection)
        setup_headers(connection)

        # Parse JSON responses automatically
        connection.response :json, content_type: /\bjson$/

        # Ensure requests are URL-encoded
        connection.use Faraday::Request::UrlEncoded

        # Configure logging if a logger is present
        setup_logger_filtering(connection, logger) if logger
      end
    end
  end
end

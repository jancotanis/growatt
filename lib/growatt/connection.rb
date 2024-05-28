require 'faraday'
require 'faraday/follow_redirects'
require 'faraday-cookie_jar'

module Growatt
  # Create connection and use cookies for authentication tokens
  module Connection
    def connection
      raise ConfigurationError, "Option for endpoint is not defined" unless endpoint

      options = setup_options
      @connection ||= Faraday::Connection.new(options) do |connection|
#        connection.use Faraday::FollowRedirects::Middleware, limit: 10
        connection.use :cookie_jar

        connection.use Faraday::Response::RaiseError
        connection.adapter Faraday.default_adapter
        setup_authorization(connection)
        setup_headers(connection)
        connection.response :json, content_type: /\bjson$/
        connection.use Faraday::Request::UrlEncoded

        setup_logger_filtering(connection, logger) if logger
      end
    end

  end
end

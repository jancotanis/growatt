# frozen_string_literal: true

module Growatt

  # Base error class for all Growatt-related exceptions.
  # Allows rescuing all Growatt-specific errors with `Growatt::GrowattError`.
  class GrowattError < StandardError; end

  # Raised when there is a configuration issue, such as missing or invalid settings.
  #
  # @example Raising a configuration error
  #   raise Growatt::ConfigurationError, "Invalid API endpoint"
  class ConfigurationError < GrowattError; end

  # Raised when an authentication attempt fails.
  #
  # @example Handling authentication failure
  #   begin
  #     client.login
  #   rescue Growatt::AuthenticationError => e
  #     puts "Login failed: #{e.message}"
  #   end
  class AuthenticationError < GrowattError; end
end

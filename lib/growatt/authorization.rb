# frozen_string_literal: true

require 'digest'
require File.expand_path('error', __dir__)

module Growatt
  # Handles authentication flow and stores session data in the global configuration.
  #
  # This module provides methods for logging into the Growatt portal, hashing passwords, 
  # and validating credentials.
  #
  module Authentication
    # Logs in to the Growatt portal using the stored credentials.
    #
    # This method:
    # - Validates that the username and password are set.
    # - Hashes the password using MD5.
    # - Sends a login request with the credentials.
    # - Processes the server response.
    #
    # @raise [ConfigurationError] If username or password is missing.
    # @raise [AuthenticationError] If authentication fails.
    # @return [Hash] The login response data if successful.
    #
    # @example Logging in to Growatt:
    #   client.login
    #
    def login
      validate_credentials
      _password = hash_password(self.password) # Hash password before sending

      _format = self.format
      self.format = 'x-www-form-urlencoded'
      response = post('newTwoLoginAPI.do', { 'userName' => self.username, 'password' => _password })
      self.format = _format
      process_response(response.body['back'])
    end

  private

    # Hashes the given password using MD5.
    #
    # This method generates an MD5 hash of the password and modifies it by replacing
    # every occurrence of '0' at even indices with 'c'.
    #
    # @param password [String] The plain-text password.
    # @return [String] The modified MD5-hashed password.
    #
    # @example Hashing a password:
    #   hash_password("mypassword") # => "5f4dcc3bcfcd204e074324a5e7565eaf"
    #
    def hash_password(password)
      password_md5 = Digest::MD5.hexdigest(password.encode('utf-8'))
      (0...password_md5.length).step(2) do |i|
        password_md5[i] = 'c' if password_md5[i] == '0'
      end
      password_md5
    end

    # Validates that the username and password are set.
    #
    # @raise [ConfigurationError] If either credential is missing.
    #
    # @example Checking credentials before login:
    #   validate_credentials # Raises ConfigurationError if missing
    #
    def validate_credentials
      raise ConfigurationError, "Username/password not set" unless username && password
    end

    # Processes the authentication response.
    #
    # If authentication is successful, stores the login data. Otherwise, raises an error.
    #
    # @param data [Hash] The response data from the Growatt portal.
    # @raise [AuthenticationError] If authentication fails.
    # @return [Hash] The login data if authentication succeeds.
    #
    # @example Handling a successful login:
    #   process_response({ "success" => true }) # Returns login data
    #
    def process_response(data)
      if data && data['success']
        @login_data = data
        data
      else
        raise AuthenticationError.new(data['error'])
      end
    end
  end
end

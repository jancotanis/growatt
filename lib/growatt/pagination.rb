# frozen_string_literal: true

require 'uri'
require 'json'

module Growatt
  # Provides pagination handling for API requests.
  module RequestPagination
    # Custom data pager for processing API responses.
    # Inherits from `WrAPI::RequestPagination::DefaultPager` and extracts relevant data from responses.
    class DataPager < WrAPI::RequestPagination::DefaultPager
      # Extracts the relevant data from the API response body.
      #
      # @param body [String, Hash] The response body from an API request.
      # @return [Hash] The parsed response data.
      #
      # @example Extracting data from a response
      #   response = { "back" => { "items" => [...] } }
      #   Growatt::RequestPagination::DataPager.data(response)
      #   # => { "items" => [...] }
      def self.data(body)
        # If the body is a Hash, return the 'back' key if it exists
        if body.is_a? Hash
          body['back'] || body
        else
          # If the body is a String, parse it as JSON
          JSON.parse(body)
        end
      end
    end
  end
end

require 'uri'
require 'json'

module Growatt

  # Defines HTTP request methods
  module RequestPagination

    class DataPager < WrAPI::RequestPagination::DefaultPager

      def self.data(body)
        # data is at 'back'
        if body.is_a? Hash
          if body['back']
            body['back']
          else
            body
          end
        else
          # in some cases wrong contenttype is returned instead of app/json
          JSON.parse(body)
        end
      end
    end
  end
end

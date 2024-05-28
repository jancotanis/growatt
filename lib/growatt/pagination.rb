require 'uri'
require 'json'

module Growatt

  # Defines HTTP request methods
  module RequestPagination

    class DataPager < WrAPI::RequestPagination::DefaultPager

      def self.data(body) 
        # data is at 'back'
        if body['back']
          body['back']
        else
          body
        end
      end
    end
  end
end

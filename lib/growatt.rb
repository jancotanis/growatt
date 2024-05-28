require "wrapi"
require File.expand_path('growatt/client', __dir__)
require File.expand_path('growatt/version', __dir__)
require File.expand_path('growatt/pagination', __dir__)

module Growatt
  extend WrAPI::Configuration
  extend WrAPI::RespondTo

  DEFAULT_UA = "Ruby Growatt API client #{Growatt::VERSION}".freeze
  # https://openapi.growatt.com/ is an option but does not work with my account
  DEFAULT_ENDPOINT = 'https://server.growatt.com/'.freeze
  DEFAULT_PAGINATION = RequestPagination::DataPager
  #
  # @return [Growatt::Client]
  def self.client(options = {})
    Growatt::Client.new({ user_agent: DEFAULT_UA, endpoint: DEFAULT_ENDPOINT, pagination_class: DEFAULT_PAGINATION }.merge(options))
  end

  def self.reset
    super
    self.endpoint   = nil
    self.user_agent = DEFAULT_UA
    self.endpoint   = DEFAULT_ENDPOINT
    self.pagination_class = DEFAULT_PAGINATION
  end
end

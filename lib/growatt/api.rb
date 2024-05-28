require "wrapi"
require File.expand_path('authorization', __dir__)
require File.expand_path('connection', __dir__)

module Growatt
  # @private
  class API

    # @private
    attr_accessor *WrAPI::Configuration::VALID_OPTIONS_KEYS

    # Creates a new API and copies settings from singleton
    def initialize(options = {})
      options = Growatt.options.merge(options)
      WrAPI::Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    def config
      conf = {}
      WrAPI::Configuration::VALID_OPTIONS_KEYS.each do |key|
        conf[key] = send key
      end
      conf
    end

    include WrAPI::Connection
    include Connection
    include WrAPI::Request
    include WrAPI::Authentication
    include Authentication

  end
end

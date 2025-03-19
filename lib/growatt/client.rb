# frozen_string_literal: true

require File.expand_path('api', __dir__)
require File.expand_path('const', __dir__)
require File.expand_path('error', __dir__)

module Growatt
  # Wrapper for the Growatt REST API
  #
  # This class provides methods to interact with the Growatt API, including:
  # - Retrieving plant and inverter data
  # - Managing inverters (turning them on/off, updating settings)
  # - Handling authentication and session data
  #
  # @note No official API documentation is available; this was reverse-engineered.
  #
  # @see Growatt::Authentication For authentication-related logic.
  class Client < API
    # Initializes the Growatt API client.
    #
    # @param options [Hash] Additional options for the API client.
    def initialize(options = {})
      super(options)
    end

    # Retrieves login session data.
    #
    # @return [Hash, nil] The login data stored in @login_data.
    def login_info
      @login_data
    end

    # Retrieves a list of plants associated with a user.
    #
    # @param user_id [String, nil] The user ID; if nil, it defaults to the logged-in user's ID.
    # @return [Hash] The list of plants.
    def plant_list(user_id = nil)
      user_id ||= login_info['user']['id']
      _plant_list({ 'userId': user_id })
    end

    # Retrieves detailed information about a plant.
    #
    # @param plant_id [String] The plant ID.
    # @param type [String] The timespan type (default: `Timespan::DAY`).
    # @param date [Time] The date for the requested timespan (default: `Time.now`).
    # @return [Hash] The plant details.
    def plant_detail(plant_id, type = Timespan::DAY, date = Time.now)
      _plant_detail({
        'plantId': plant_id,
        'type': type,
        'date': timespan_date(type, date)
      })
    end

    # Retrieves plant information.
    #
    # @param plant_id [String] The plant ID.
    # @return [Hash] Plant information, including available devices.
    def plant_info(plant_id)
      _plant_info({
        'op': 'getAllDeviceList',
        'plantId': plant_id,
        'pageNum': 1,
        'pageSize': 1
      })
    end

    # Retrieves a list of devices in a plant.
    #
    # @param plant_id [String] The plant ID.
    # @return [Array] A list of devices.
    def device_list(plant_id)
      plant_info(plant_id).deviceList
    end

    # Retrieves a list of inverters in a plant.
    #
    # @param plant_id [String] The plant ID.
    # @return [Array] A list of inverters.
    def inverter_list(plant_id)
      devices = device_list(plant_id)
      devices.select { |device| 'inverter'.eql? device.deviceType }
    end

    # Retrieves data for inverter control.
    #
    # @param inverter_id [String] The inverter's serial number.
    # @return [Hash] The inverter's control data.
    def inverter_control_data(inverter_id)
      _inverter_api({
        'op': 'getMaxSetData',
        'serialNum': inverter_id
      }).obj.maxSetBean
    end

    # Updates an inverter's setting.
    #
    # @param serial_number [String] The inverter's serial number.
    # @param command [String] The command to execute.
    # @param param_id [String] The parameter ID.
    # @param parameters [Array, Hash] The parameters to send.
    # @return [Boolean] `true` if the update was successful, `false` otherwise.
    def update_inverter_setting(serial_number, command, param_id, parameters)
      command_parameters = {
        'op': command,
        'serialNum': serial_number,
        'paramId': param_id
      }

      parameters = parameters.map.with_index { |value, index| ["param#{index + 1}", value] }.to_h if parameters.is_a? Array
      self.format = 'x-www-form-urlencoded'
      data = JSON.parse(post('newTcpsetAPI.do', command_parameters.merge(parameters)).body)
      self.format = :json
      data['success']
    end

    # Turns an inverter on or off.
    #
    # @param serial_number [String] The inverter's serial number.
    # @param on [Boolean] `true` to turn on, `false` to turn off.
    # @return [Boolean] `true` if the operation was successful.
    def turn_inverter(serial_number, on = true)
      onoff = (on ? Inverter::ON : Inverter::OFF)
      update_inverter_setting(serial_number, 'maxSetApi', 'max_cmd_on_off', [onoff])
    end

    # Checks if an inverter is turned on.
    #
    # @param serial_number [String] The inverter's serial number.
    # @return [Boolean] `true` if the inverter is on, `false` otherwise.
    def inverter_on?(serial_number)
      status = inverter_control_data(serial_number)
      Inverter::ON.eql? status.max_cmd_on_off
    end

    # Sets export limit for an inverter.
    #
    # @param serial_number [String] The inverter's serial number.
    # @param enable [String] `ExportLimit::DISABLE`, `ExportLimit::WATT`, or `ExportLimit::PERCENTAGE`.
    # @param value [Numeric, nil] The export limit value (required unless disabled).
    # @return [Boolean] `true` if the setting update was successful.
    def export_limit(serial_number, enable, value = nil)
      if ExportLimit::DISABLE.eql? enable
        params = [0]
      else
        validate_export_parameters(enable, value)
        params = [1, value, enable]
      end
      update_inverter_setting(serial_number, 'maxSetApi', 'backflow_setting', params)
    end

    # Utility function to get a formatted date based on timespan.
    #
    # @param timespan [String] The timespan type (`Timespan::DAY`, `Timespan::MONTH`, `Timespan::YEAR`).
    # @param date [Time] The date (default: `Time.now`).
    # @return [String] The formatted date.
    def timespan_date(timespan = Timespan::DAY, date = Time.now)
      case timespan
      when Timespan::YEAR
        date.strftime("%Y")
      when Timespan::MONTH
        date.strftime("%Y-%m")
      when Timespan::DAY
        date.strftime("%Y-%m-%d")
      end
    end

    # Retrieves inverter data based on timespan.
    #
    # @param inverter_id [String] The inverter's ID.
    # @param type [String] The timespan type.
    # @param date [Time] The date (default: `Time.now`).
    # @return [Hash] The inverter data.
    def inverter_data(inverter_id, type = Timespan::DAY, date = Time.now)
      operator =
        case type
        when Timespan::DAY then 'getInverterData_max'
        when Timespan::MONTH then 'getMaxMonthPac'
        when Timespan::YEAR then 'getMaxYearPac'
        end

      _inverter_api({
        'op': operator,
        'id': inverter_id,
        'type': 1,
        'date': timespan_date(type, date)
      })
    end

    private

    # Defines API endpoints dynamically.
    #
    # @param method [Symbol] The method name.
    # @param path [String] The API endpoint.
    def self.api_endpoint(method, path)
      define_method(method) do |params = {}|
        get(path, params) do |request|
          request.headers['Accept'] = "application/#{format}"
        end
      end
    end

    api_endpoint :_plant_list, 'PlantListAPI.do'
    api_endpoint :_plant_detail, 'PlantDetailAPI.do'
    api_endpoint :_inverter_api, 'newInverterAPI.do'
    api_endpoint :_plant_info, 'newTwoPlantAPI.do'

    # Validates export limitation parameters.
    def validate_export_parameters(enable, value)
      unless [ExportLimit::WATT, ExportLimit::PERCENTAGE].include?(enable)
        raise ArgumentError, "Export limitation must be ExportLimit::WATT or ExportLimit::PERCENTAGE"
      end
      raise ArgumentError, "Value is required" unless value
      raise ArgumentError, "Value must be numeric" unless value.is_a? Numeric
    end
  end
end

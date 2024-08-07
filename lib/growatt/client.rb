require File.expand_path('api', __dir__)
require File.expand_path('const', __dir__)
require File.expand_path('error', __dir__)

module Growatt
  # Wrapper for the Growatt REST API
  #
  # @see no API documentation, reverse engineered
  class Client < API

    def initialize(options = {})
      super(options)
    end

    # access data returned from login
    def login_info
      @login_data
    end
    def plant_list(user_id=nil)
      user_id = login_info['user']['id'] unless user_id
      _plant_list({'userId':user_id})
    end
    def plant_detail(plant_id,type=Timespan::DAY,date=Time.now)
      _plant_detail( {
        'plantId': plant_id,
        'type': type,
        'date': timespan_date(type,date)
      })
    end
    def plant_info(plant_id)
      _plant_info({
        'op': 'getAllDeviceList',
        'plantId': plant_id,
        'pageNum': 1,
        'pageSize': 1
      })
    end
    def device_list(plant_id)
      plant_info(plant_id).deviceList
    end

    def inverter_list(plant_id)
      devices = device_list(plant_id)
      devices.select { |device| 'inverter'.eql? device.deviceType  }
    end

    # get data for invertor control
    def inverter_control_data(inverter_id)
      _inverter_api({
        'op': 'getMaxSetData',
        'serialNum': inverter_id
      }).obj.maxSetBean
    end

    def update_inverter_setting(serial_number,command,param_id,parameters)
      command_parameters = {
        'op': command,
        'serialNum': serial_number,
        'paramId': param_id
      }
      # repeated values to hash { param1: value1 }

      parameters = parameters.map.with_index { |value, index| ["param#{index + 1}", value] }.to_h if parameters.is_a? Array
      self.format = 'x-www-form-urlencoded'
      data = JSON.parse(post('newTcpsetAPI.do',command_parameters.merge(parameters)).body)
      self.format = :json
      data['success']
    end

    # turn invertor on of off
    def turn_inverter(serial_number,on=true)
      onoff = (on ? Inverter::ON : Inverter::OFF )
      update_inverter_setting(serial_number,'maxSetApi','max_cmd_on_off',[onoff])
    end

    # check if invertor is turned on
    def inverter_on?(serial_number)
      status = inverter_control_data(serial_number)
      Inverter::ON.eql? status.max_cmd_on_off
    end

    def export_limit(serial_number,enable,value=nil)
      if ExportLimit::DISABLE.eql? enable
        params = [0]
      else
        validate_export_parameters(enable,value)
        params = [1, value, enable]
      end
      update_inverter_setting(serial_number,'maxSetApi','backflow_setting',params)
    end

    # utility function to get date accordign timespan month/day
    def timespan_date(timespan=Timespan::DAY,date=Time.now)
      if Timespan::YEAR.eql? timespan
        date.strftime("%Y")
      elsif Timespan::MONTH.eql? timespan
        date.strftime("%Y-%m")
      elsif Timespan::DAY.eql? timespan
        date.strftime("%Y-%m-%d")
      end
    end

    #
    # functions below are copied from python example code but not sure if these work with MOD9000 inverters
    #
    def inverter_data(inverter_id,type=Timespan::DAY,date=Time.now)
      if Timespan::DAY.eql? type
        operator = 'getInverterData_max'
      elsif Timespan::MONTH.eql? type
        operator = 'getMaxMonthPac'
      elsif Timespan::YEAR.eql? type
        operator = 'getMaxYearPac'
      end
      _inverter_api({
        'op': operator,
        'id': inverter_id,
        'type': 1,
        'date': timespan_date(type,date)
      })
    end
=begin
    def inverter_detail(inverter_id)
      _inverter_api({
        'op': 'getInverterDetailData',
        'inverterId': inverter_id
      })
    end
    def inverter_detail_two(inverter_id)
      _inverter_api({
        'op': 'getInverterDetailData_two',
        'inverterId': inverter_id
      })
    end
=end
    def update_mix_inverter_setting(serial_number, setting_type, parameters)
      update_inverter_setting(serial_number,'mixSetApiNew',setting_type,parameters)
    end
    def update_ac_inverter_setting(serial_number, setting_type, parameters)
      update_inverter_setting(serial_number,'spaSetApi',setting_type,parameters)
    end


  private
    def self.api_endpoint(method,path)
      # all records
      self.send(:define_method, method) do |params = {}|
        # return data result
        get(path,params) do |request|
          request.headers['Accept'] = "application/#{format}"
        end
      end
    end
    api_endpoint :_plant_list, 'PlantListAPI.do'
    api_endpoint :_plant_detail, 'PlantDetailAPI.do'
    api_endpoint :_inverter_api, 'newInverterAPI.do'
    api_endpoint :_plant_info, 'newTwoPlantAPI.do'

    def validate_export_parameters(enable,value)
      raise ArgumentError, "exportlimitation enable should be ExportLimit::WATT or ExportLimit::PERCENTAGE" unless [ExportLimit::WATT,ExportLimit::PERCENTAGE].include? enable
      raise ArgumentError, "Value should be set for export limitation" unless value
      raise ArgumentError, "Value should be numeric" unless value.is_a? Numeric
    end
  end
end

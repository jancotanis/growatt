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
      inverters = devices.select { |device| 'inverter'.eql? device.deviceType  }
    end

    def inverter_data(inverter_id,type=Timespan::DAY,date=Time.now)
      _inverter_api({
        'op': 'getInverterData',
        'id': inverter_id,
        'type': type,
        'date': timespan_date(type,date)
      })
    end
    def inverter_detail(inverter_id)
      _inverter_api({
        'op': 'getInverterDetailData',
        'id': inverter_id
      })
    end
    def inverter_detail_two(inverter_id)
      _inverter_api({
        'op': 'getInverterDetailData_two',
        'id': inverter_id
      })
    end
    def update_inverter_setting(serial_number,command,setting_type,parameters)
      command_parameters = {
        'op': command,
        'serialNum': serial_number,
        'type': setting_type
      }
      # repeated values to hash { param1: value1 }
      
      parameters = parameters.map.with_index { |value, index| ["param#{index + 1}", value] }.to_h if parameters.is_a? Array

      data = post('newTcpsetAPI.do',command_parameters.merge(parameters))
    end
    def update_mix_inverter_setting(serial_number, setting_type, parameters)
      update_inverter_setting(serial_number,'mixSetApiNew',setting_type,parameters)
    end
    def update_ac_inverter_setting(serial_number, setting_type, parameters)
      update_inverter_setting(serial_number,'spaSetApi',setting_type,parameters)
    end
    

    # utility function to get date accordign timespan month/day
    def timespan_date(timespan=Timespan::DAY,date=Time.now)
      if Timespan::MONTH.eql? timespan
        date.strftime("%Y-%m")
      else
        date.strftime("%Y-%m-%d")
      end
    end

  private
    def self.api_endpoint(method,path)
      # all records
      self.send(:define_method, method) do |params = {}|
        data = get(path,params)
      end
    end
    api_endpoint :_plant_list, 'PlantListAPI.do'
    api_endpoint :_plant_detail, 'PlantDetailAPI.do'
    api_endpoint :_inverter_api, 'newInverterAPI.do'
    api_endpoint :_plant_info, 'newTwoPlantAPI.do'

  end
end

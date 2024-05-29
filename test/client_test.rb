require 'dotenv'
require 'logger'
require 'test_helper'

def p m, o
#  puts "#{m}: #{o.inspect}"
end

describe 'client' do
  before do
    @client = Growatt.client
    @client.login
  end

  it '#1 GET info' do

  end

  it "#2 plant/device list" do
    plants = @client.plant_list

p "\n* plants", plants
    plant_id = plants.data.first.plantId
    assert plant_id, "plant_id should not be nil"

    detail = @client.plant_detail(plant_id)
p "\n* plant detail", detail
    assert value(detail.plantData.plantId).must_equal(plant_id), 'correct plantId/structure'

    plant_info = @client.plant_info(plant_id)
p "\n* plant info:", plant_info

    devices = @client.device_list(plant_id)
p "\n* devices:", plant_info.deviceList
    inverter = devices.first
    # turn device on
    result = @client.turn_inverter(inverter.deviceSn,true)
p "\n* turnon result:", result
    is_on = @client.inverter_on?(inverter.deviceSn)

    assert is_on, "Inverter should be on"
    assert result, "inverter on should be success"
  end
  it "#3 export limitation parameters" do

    assert_raises ArgumentError do
      @client.export_limitation('xxxx', 4)
      flunk( 'ArgumentError expected, invalid limtation' )
    end
    assert_raises ArgumentError do
      @client.export_limitation('xxxx', Growatt::Inverter::WATT)
      flunk( 'ArgumentError expected, no value given for WATTs' )
    end
    assert_raises ArgumentError do
      @client.export_limitation('xxxx',Growatt:: Inverter::PERCENTAGE)
      flunk( 'ArgumentError expected, no value given for PERCENTAGEs' )
    end
  end
end

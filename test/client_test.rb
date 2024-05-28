require 'dotenv'
require 'logger'
require 'test_helper'

def p m, o
  puts "#{m}: #{o.inspect}"
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
puts plant_info.class

    devices = @client.device_list(plant_id)
p "\n* devices:", plant_info.deviceList
    inverter = devices.first
    # turn device on
    assert @client.turn_inverter(inverter.deviceSn,true), "inverter on should be success"
p "\n* turnon result:", result
    assert @client.inverter_on?(inverter.deviceSn), "Inverter should be on"
  end
end

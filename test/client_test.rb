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
p 'plants', plants
    plant_id = plants.data.first.plantId
    detail = @client.plant_detail(plant_id)
p 'plant detail', detail
    devices = @client.device_list(plant_id)
p 'devices:', devices
p 'deviceslist:', devices.deviceList
    #inverter_id = detail
  end
end

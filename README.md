# Growatt API
[![Version](https://img.shields.io/gem/v/growatt.svg)](https://rubygems.org/gems/growatt)
[![Maintainability](https://api.codeclimate.com/v1/badges/60e7b62db0513a99ae4a/maintainability)](https://codeclimate.com/github/jancotanis/growatt/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/60e7b62db0513a99ae4a/test_coverage)](https://codeclimate.com/github/jancotanis/growatt/test_coverage)

This is a wrapper for the Growatt rest API. Main objective is to turn inverter on/off. This has been testen with MOD-9000TL-X.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'growatt'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install growatt

## Usage

Before you start making the requests to API provide the username and password using with Shinephone app.

```ruby
require 'growatt'
require 'logger'
TEST_LOGGER = './test.log'
# use do block
Growatt.configure do |config|
  config.username = ENV['GROWATT_USERNAME']
  config.password = ENV['GROWATT_PASSWORD']
  config.logger = Logger.new(TEST_LOGGER)
end

# or configure with options hash
client = Growatt.client
client.login

```

## Resources
### Authentication and configuration
```ruby
# setup
#
begin
  client = Growatt.client
  client.login
  # turn invertor off
  client.turn_inverter('<serial_no>', false)
rescue Growatt::AuthenticationError => e
  puts "Error logging in growatt api"
  puts e
end
```
### Read data
```
# create client (don't forget to configure authentication)
# get data for first inverter for first defined plant
plants = client.plant_list
plant_id = plants.data.first.plantId
devices = client.inverter_list(plant_id)
inverter = devices.first

yymm = Time.now.strftime("%Y%m")
puts "- loading period #{yymm}"
data = client.inverter_data(inverter.deviceSn,Growatt::Timespan::MONTH,current_month)

```

### Control
```
# continu from read data example above
inverter = devices.first

# turn inverter on/of
client.turn_inverter(inverter.deviceSn, false)

# or limit energy export
client.export_limit(inverter.deviceSn,Growatt::ExportLimit::PERCENTAGE, 100)
# allow energy export to grid
client.export_limit(inverter.deviceSn,Growatt::ExportLimit::DISABLE)
```

## Publishing

1. Update version in [version.rb](lib/growatt/version.rb).
2. Add release to [CHANGELOG.md](CHANGELOG.md)
3. Commit.
4. Test build.
```
> rake build

```
5. Release
```
> rake release

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jancotanis/growatt.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
"# growatt"

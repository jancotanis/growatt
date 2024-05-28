# Growatt API
[![Version](https://img.shields.io/gem/v/growatt.svg)](https://rubygems.org/gems/growatt)

This is a wrapper for the Growatt rest API.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'growatt'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tibber

## Usage

Before you start making the requests to API provide the endpoint and api key using the configuration wrapping.

```ruby
require 'growatt'
require 'logger'

# use do block
Growatt.configure do |config|
  config.access_token = ENV['GROWATT_ACCESS_TOKEN']
  config.logger = Logger.new(TEST_LOGGER)
end

# or configure with options hash
client = Growatt.client
client.login

```

## Resources
### Authentication
```ruby
# setup
#
begin
  client = Growatt.client
  client.login
rescue Growatt::AuthenticationError => e
  puts "Error logging in growatt api"
  puts e
end
```



### Graph QL Data resources
Endpoint for data related requests

```ruby
# show todays prices
prices = client.price_info

prices.homes.each do |home|
  puts "Today's prices:"
  home.currentSubscription.priceInfo.today.each do |hour|
    puts "#{hour.startsAt} #{hour.total} #{hour.currency} (#{hour.energy} + #{hour.tax})"
  end
end

```

|Resource|API endpoint|
|:--|:--|
|.information | returns `name userId login accountType websocketSubscriptionUrl homes including homes meteringPointData, subscriptions` and `features` |
|.price_info|price information for all `homes[id,currentSubscription{priceInfo{current,today[],tomorrow[]}}]`  |
|.consumption(home_id, resolution, count)|Array of `home.consumption.nodes[]`: `from to cost unitPrice unitPriceVAT consumption consumptionUnit`|
|.send_push_notification(title, message, screen_to_open)| send notificartion ot devices and returns `successful` & `pushedToNumberOfDevices`|

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

Bug reports and pull requests are welcome on GitHub at https://github.com/jancotanis/tibber.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
"# growatt" 

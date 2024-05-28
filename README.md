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

    $ gem install growatt

## Usage

Before you start making the requests to API provide the endpoint and api key using the configuration wrapping.

```ruby
require 'growatt'
require 'logger'

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

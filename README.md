# togglehq

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'togglehq'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blabbr

## Configuration

```ruby
Togglehq.configure do |config|
  config.client_id = ENV['TOGGLEHQ_CLIENT_ID']
  config.client_secret = ENV['TOGGLEHQ_CLIENT_SECRET']
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/togglehq/togglehq-gem.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

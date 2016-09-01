# togglehq

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'togglehq'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install togglehq

## Configuration

```ruby
require 'togglehq'

Togglehq.configure do |config|
  # These should be set to the "Master OAuth" client id and client secret
  # for your app from the ToggleHQ dashboard
  config.client_id = ENV['TOGGLEHQ_CLIENT_ID']
  config.client_secret = ENV['TOGGLEHQ_CLIENT_SECRET']

  # To log the HTTP requests/responses to and from the ToggleHQ API, set log_requests to true (defaults to false)
  config.log_requests = true
end
```

## Usage

### ToggleHQ Notify

#### Users

Create a user for your app

```ruby
user = Togglehq::Notify::User.new(:identifier => "abcdef0123456789")
user.save
```

Find an existing user for your app
```ruby
user = Togglehq::Notify::User.find_by_identifier("abcdef0123456789")
```

If a user with the given identifier cannot be found, `nil` will be returned.

Alternatively, you can call `Togglehq::Notify::User.find_by_identifier!`, which will raise a RuntimeError if the given user cannot be found.


### Settings

Get all setting groups and settings for your app
```ruby
settings = Togglehq::Notify::Settings.all
```

A `Togglehq::Notify::Settings` object has a `groups` attribute which contains an array of all setting groups:
```ruby
settings.groups
 => [{"name"=>"Friends", "key"=>"friends", "settings"=>[{"name"=>"Friend Request", "key"=>"friend_request", "default"=>true}]}] 
```

Each setting group contains a name, a key, and an array of settings, which also have a name, key, and default value.

Enable a setting for a user
```ruby
user.enable_setting!("group_key", "setting_key")
```
This will return true upon success, and raise a RuntimeError on failure.

Disable a setting for a user
```ruby
user.disable_setting!("group_key", "setting_key")
```
This will return true upon success, and raise a RuntimeError on failure.

### Notifications

To send push notifications, first construct a `Togglehq::Notify::Notification` object specifying a setting group key, setting key, and message.

```ruby
notification = Togglehq::Notify::Notification.new(:group_key => "friends", :setting_key => "friend_request", :message => "You have a new friend request!")
```
To send this notification to a single user:

```ruby
user = Togglehq::Notify::User.find_by_identifier("abc123")
notification.send(user)
```
This will return true upon success, and raise a RuntimeError on failure.

To send this notification to a batch of users:
```ruby
user1 = Togglehq::Notify::User.new(:identifier => "abc123")
user2 = Togglehq::Notify::User.new(:identifier => "def456")
...
userN = Togglehq::Notify::User.new(:identifier => "xyz890")

notification.batch_send([user1, user2, ..., user2])
```
This will return true upon success, and raise a RuntimeError on failure.

To send this notification as a global message to all of the users in your app:
```ruby
notification.send_global
```
This will return true upon success, and raise a RuntimeError on failure.


## Gotchas

If you encounter SSL errors while using the togglehq-gem similar to the following:

```
Faraday::SSLError: SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed
```

ToggleHQ's SSL certificate is issued by Comodo. Comodo recently added a new certificate root, which may not be in your Ruby/OpenSSL trusted root certificates file. To find the location of your root file:

```ruby
require 'openssl'
puts OpenSSL::X509::DEFAULT_CERT_FILE
```

This will output something like `/usr/local/etc/openssl/cert.pem`. Open this file, and add the "Comodo RSA Certification Authority (SHA-2)"" root cert PEM found [here](https://support.comodo.com/index.php?/Default/Knowledgebase/Article/View/969/108/root-comodo-rsa-certification-authority-sha-2) to this file.

For more gory details, [see this excellent blog post](http://mislav.net/2013/07/ruby-openssl/) and this [StackOverflow question](http://stackoverflow.com/questions/36966650/ruby-nethttp-responds-with-opensslsslsslerror-certificate-verify-failed).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/togglehq/togglehq-gem.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

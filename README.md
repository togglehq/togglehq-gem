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

### Users

Create a user for your app

```ruby
user = Togglehq::User.new(:identifier => "abcdef0123456789")
user.save
```

Find an existing user for your app
```ruby
user = Togglehq::User.find_by_identifier("abcdef0123456789")
```

If a user with the given identifier cannot be found, `nil` will be returned.

Alternatively, you can call `Togglehq::User.find_by_identifier!`, which will raise a RuntimeError if the given user cannot be found.


### ToggleHQ Notify Usage


#### Preferences

Get all preference categories and preferences for your app
```ruby
preferences = Togglehq::Notify::Preferences.all
```

A `Togglehq::Notify::Preferences` object has a `categories` attribute which contains an array of all preference categories:
```ruby
preferences.categories
 => [{"name"=>"Friends", "key"=>"friends", "preferences"=>[{"name"=>"Friend Request", "key"=>"friend_request", "default"=>true}]}] 
```

Each preference category contains a name, a key, and an array of preferences, which also have a name, key, and default value.


#### User Preferences

`Togglehq::Notify::UserPreferences` enapsulates a specific user's notification preferences for your app.
Create one by passing a `Togglehq::User` object:

```ruby
user_preferences = Togglehq::Notify::UserPreferences.new(user)
```

Get the user's preferences by calling the `categories` method:
```ruby
user_preferences.categories
 => [{"name"=>"Friends", "key"=>"friends", "preferences"=>[{"name"=>"Friend Request", "key"=>"friend_request", "default"=>true, "enabled"=>true}]}] 
```

Like `Togglehq::Notify::Preferences`, a `Togglehq::Notify::UserPreferences` object has a `categories` attribute which contains an array of all preference categories.
Each preference category contains a name, a key, and an array of preferences, which also have a name, key, and default value.
In addition, each user preference contains an enabled flag, indicating whether the user has enabled that particular preference or not.

Please note that a `Togglehq::Notify::UserPreferences` object's `categories` property is memoized when fetched from the ToggleHQ API. To reload
the preferences, call the `reload!` method on the `Togglehq::Notify::UserPreferences` object:

```ruby
user_preferences.reload!
```

Enable a preference for a user
```ruby
user_preferences.enable_preference!("category_key", "preference_key")
```
This will return true upon success, and raise a RuntimeError on failure.

Disable a preference for a user
```ruby
user_preferences.disable_preference!("category_key", "preference_key")
```
This will return true upon success, and raise a RuntimeError on failure.

#### Notifications

To send push notifications, first construct a `Togglehq::Notify::Notification` object specifying a preference category key, preference key, and message.

```ruby
notification = Togglehq::Notify::Notification.new(:category_key => "friends", :preference_key => "friend_request", :message => "You have a new friend request!")
```
To send this notification to a single user:

```ruby
user = Togglehq::User.find_by_identifier("abc123")
notification.send(user)
```
This will return true upon success, and raise a RuntimeError on failure.

To send this notification to a batch of users:
```ruby
user1 = Togglehq::User.new(:identifier => "abc123")
user2 = Togglehq::User.new(:identifier => "def456")
...
userN = Togglehq::User.new(:identifier => "xyz890")

notification.batch_send([user1, user2, ..., user2])
```
This will return true upon success, and raise a RuntimeError on failure.

To send this notification as a global message to all of the users in your app:
```ruby
notification.send_global
```
This will return true upon success, and raise a RuntimeError on failure.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/togglehq/togglehq-gem.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

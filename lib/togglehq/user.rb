module Togglehq
  class User
    attr_accessor :identifier
    attr_accessor :settings

    # Finds an app user by the given identifier. If no record is found, returns nil.
    def self.find_by_identifier(identifier)
      response = Togglehq::Request.new("/users/#{identifier}").get!
      if response.status == 404
        return nil
      elsif response.status == 200
        json = JSON.parse(response.body)
        user = Togglehq::User.new
        user.persisted!
        user.identifier = identifier
        user.settings = json["settings"]
        return user
      else
        raise "Unexpected error finding user"
      end
    end

    # Like find_by_identifier, except that if no record is found, raises an RuntimeError.
    def self.find_by_identifier!(identifier)
      user = self.find_by_identifier(identifier)
      raise "Could not find user with identifier #{identifier}"
    end

    # Saves a new user
    def save
      response = Togglehq::Request.new("/users", {"user" => {"identifier" => self.identifier}}).post!
      if response.status == 200
        self.persisted!
        json = JSON.parse(response.body)
        if json.has_key?("message")
          if json["message"] == "user already exists"
            # load this user's settings
            user = Togglehq::User.find_by_identifier(self.identifier)
            self.settings = user.settings
          end
        end
      else
        raise "Unexpected error saving user"
      end
    end

    # @private
    def persisted!
      @persisted = true
    end
  end
end

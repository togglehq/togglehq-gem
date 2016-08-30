module Togglehq
  module Notify
    class User
      attr_accessor :identifier
      attr_accessor :settings

      def initialize(params = {})
        @identifier = params[:identifier]
        @settings = params[:settings]
      end

      # Finds an app user by the given identifier. If no record is found, returns nil.
      def self.find_by_identifier(identifier)
        response = Togglehq::Request.new("/users/#{identifier}").get!
        if response.status == 404
          return nil
        elsif response.status == 200
          json = JSON.parse(response.body)
          user = Togglehq::Notify::User.new
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
        raise "Could not find user with identifier #{identifier}" if user.nil?
      end

      # Saves a new user
      def save
        response = Togglehq::Request.new("/users", {"user" => {"identifier" => self.identifier}}).post!
        if response.status == 200
          self.persisted!
          json = JSON.parse(response.body)
          if json.has_key?("message") && json["message"] == "user already exists"
            # load this user's settings
            user = Togglehq::Notify::User.find_by_identifier(self.identifier)
            self.settings = user.settings
          end
          return true
        else
          raise "unexpected error saving user"
        end
      end

      # Enables a setting for this user.
      # @param group_key [String] the key of the settings group
      # @param setting_key [String] the key of the setting within the group
      # @raise [RuntimeError] raised if either the group or setting keys are invalid
      def enable_setting!(group_key, setting_key)
        response = Togglehq::Request.new("/settings/enable",
                                         {"user" => {"identifier" => self.identifier}, "group" => group_key, "setting" => setting_key}).patch!
        if response.status == 200
          return true
        elsif response.status == 404
          json = JSON.parse(response.body)
          raise json["message"]
        else
          raise "unexpected error enabling setting"
        end
      end

      # Disables a setting for this user.
      # @param group_key [String] the key of the settings group
      # @param setting_key [String] the key of the setting within the group
      # @raise [RuntimeError] raised if either the group or setting keys are invalid
      def disable_setting!(group_key, setting_key)
        response = Togglehq::Request.new("/settings/disable",
                                         {"user" => {"identifier" => self.identifier}, "group" => group_key, "setting" => setting_key}).patch!
        if response.status == 200
          return true
        elsif response.status == 404
          json = JSON.parse(response.body)
          raise json["message"]
        else
          raise "unexpected error disabling setting"
        end
      end

      # @private
      def persisted!
        @persisted = true
      end
    end
  end
end

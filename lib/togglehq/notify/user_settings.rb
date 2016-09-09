require 'delegate'

module Togglehq
  module Notify
    class UserSettings < SimpleDelegator

      # Gets the current settings for this user.
      def groups
        @groups ||= reload!
      end

      # Enables a setting for this user.
      # @param group_key [String] the key of the settings group
      # @param setting_key [String] the key of the setting within the group
      # @raise [RuntimeError] raised if either the group or setting keys are invalid
      def enable_setting!(group_key, setting_key)
        response = Togglehq::Request.new("/settings/enable",
                                         {"user" => {"identifier" => self.identifier}, "group" => group_key, "setting" => setting_key}).patch!
        if response.status == 200
          if @groups
            group = @groups.find {|g| g["key"] == group_key}
            setting = group["settings"].find {|s| s["key"] == setting_key} if group
            setting["enabled"] = true if setting
          end
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
          if @groups
            group = @groups.find {|g| g["key"] == group_key}
            setting = group["settings"].find {|s| s["key"] == setting_key} if group
            setting["enabled"] = false if setting
          end
          return true
        elsif response.status == 404
          json = JSON.parse(response.body)
          raise json["message"]
        else
          raise "unexpected error disabling setting"
        end
      end

      # Reloads this UserSettings from the ToggleHQ API
      def reload!
        response = Togglehq::Request.new("/settings", {"user" => {"identifier" => self.identifier}}).get!
        if response.status == 200
          @groups = JSON.parse(response.body)
          return @groups
        elsif response.status == 404
          raise "user not found"
        else
          raise "Unexpected error getting app settings"
        end
      end
    end
  end
end

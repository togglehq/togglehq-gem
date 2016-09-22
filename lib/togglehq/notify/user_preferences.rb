require 'delegate'

module Togglehq
  module Notify
    class UserPreferences < SimpleDelegator

      # Gets the current preferences for this user.
      def categories
        @categories ||= reload!
      end

      # Enables a preference for this user.
      # @param category_key [String] the key of the preference category
      # @param preference_key [String] the key of the preference within the category
      # @raise [RuntimeError] raised if either the category or preference keys are invalid
      def enable_preference!(category_key, preference_key)
        response = Togglehq::Request.new("/preferences/enable",
                                         {"user" => {"identifier" => self.identifier}, "category" => category_key, "preference" => preference_key}).patch!
        if response.status == 200
          if @categories
            category = @categories.find {|g| g["key"] == category_key}
            preference = category["preferences"].find {|s| s["key"] == preference_key} if category
            preference["enabled"] = true if preference
          end
          return true
        elsif response.status == 404
          json = JSON.parse(response.body)
          raise json["message"]
        else
          raise "unexpected error enabling preference"
        end
      end

      # Disables a preference for this user.
      # @param cateogry_key [String] the key of the preference category
      # @param preference_key [String] the key of the preference within the category
      # @raise [RuntimeError] raised if either the category or preference keys are invalid
      def disable_preference!(category_key, preference_key)
        response = Togglehq::Request.new("/preferences/disable",
                                         {"user" => {"identifier" => self.identifier}, "category" => category_key, "preference" => preference_key}).patch!
        if response.status == 200
          if @categories
            category = @categories.find {|g| g["key"] == category_key}
            preference = category["preferences"].find {|s| s["key"] == preference_key} if category
            preference["enabled"] = false if preference
          end
          return true
        elsif response.status == 404
          json = JSON.parse(response.body)
          raise json["message"]
        else
          raise "unexpected error disabling preference"
        end
      end

      # Reloads this UserPreferences from the ToggleHQ API
      def reload!
        response = Togglehq::Request.new("/preferences", {"user" => {"identifier" => self.identifier}}).get!
        if response.status == 200
          @categories = JSON.parse(response.body)
          return @categories
        elsif response.status == 404
          raise "user not found"
        else
          raise "Unexpected error getting user preferences"
        end
      end
    end
  end
end

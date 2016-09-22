require 'json'

module Togglehq
  module Notify
    class Preferences
      attr_accessor :categories

      def initialize(params = {})
        @categories = params[:categories]
      end

      # Gets all available notification categories and their associated preferences for the current app
      # @return an array of notification categories
      def self.all
        response = Togglehq::Request.new("/preferences").get!
        if response.status == 200
          json = JSON.parse(response.body)
          preferences = Togglehq::Notify::Preferences.new(categories: json)
          return preferences
        else
          raise "Unexpected error getting app preferences"
        end
      end
    end
  end
end

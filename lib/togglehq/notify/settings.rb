require 'json'

module Togglehq
  module Notify
    class Settings
      attr_accessor :groups

      def initialize(params = {})
        @groups = params[:groups]
      end

      # Gets all available setting groups and their associated settings for the current app
      # @return an array of setting groups
      def self.all
        response = Togglehq::Request.new("/settings").get!
        if response.status == 200
          json = JSON.parse(response.body)
          settings = Togglehq::Notify::Settings.new(groups: json)
          return settings
        else
          raise "Unexpected error getting app settings"
        end
      end
    end
  end
end

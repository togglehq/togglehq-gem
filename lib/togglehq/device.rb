module Togglehq
  class Device
    attr_accessor :os, :uuid, :os_version, :manufacturer, :model

    def initialize(params = {})
      @os = params[:os]
      @uuid = params[:uuid]
      @os_version = params[:os_version]
      @manufacturer = params[:manufacturer]
      @model = params[:model]
    end

    # Enables a device to receive notifications
    # @param token [String] the token of the device
    # @raise [RuntimeError] raised if the device is invalid or not found
    def enable!(token)
      response = Togglehq::Request.new("/devices/enable",{"device" => {"uuid" => self.uuid, "token" => token}}).patch!
      if response.status == 200
        return true
      elsif response.status == 404
        json = JSON.parse(response.body)
        raise json["message"]
      else
        raise "unexpected error enabling the device"
      end
    end

    # Assigns a device to a specific user
    # @param user_identifier [String] the identifier of the user
    # @raise [RuntimeError] raised if either the device or user is invalid or not found
    def assign!(user_identifier)
      response = Togglehq::Request.new("/devices/assign",{"device" => {"uuid" => self.uuid}, "user" => {"identifier" => user_identifier}}).patch!
      if response.status == 200
        return true
      elsif response.status == 404
        json = JSON.parse(response.body)
        raise json["message"]
      else
        raise "unexpected error assigning the device"
      end
    end

    # Unassigns a device from all users
    # @raise [RuntimeError] raised if either the device or user is invalid or not found
    def unassign!
      response = Togglehq::Request.new("/devices/unassign",{"device" => {"uuid" => self.uuid}}).patch!
      if response.status == 200
        return true
      elsif response.status == 404
        json = JSON.parse(response.body)
        raise json["message"]
      else
        raise "unexpected error unassigning the device"
      end
    end

    # Saves a new user
    def save
      response = Togglehq::Request.new("/devices", {"device" => {"os" => self.os, "os_version" => self.os_version, "manufacturer" => self.manufacturer, "model" => self.model}}).post!
      if response.status == 200
        self.persisted!
        json = JSON.parse(response.body)
        self.uuid = json["device"]["uuid"]
        return true
      else
        raise "unexpected error saving the device"
      end
    end

    # @private
    def persisted!
      @persisted = true
    end
  end
end

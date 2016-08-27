module Togglehq
  class User
    attr_accessor :identifier
    attr_accessor :settings

    def self.find_by_identifier(identifier)
      response = Togglehq::Request.new("users/#{identifier}").get!
      if response.status == 404
        puts "NOT FOUND"
      elsif response.status == 200
        json = JSON.parse(response.body)
        user = Togglehq::User.new
        user.identifier = identifier
        user.settings = json["settings"]
        return user
      end
    end
  end
end

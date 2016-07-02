module Togglehq
  class Config
    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :uri
    attr_accessor :access_token
    attr_accessor :refresh_token

    def initialize
      @uri = "https://api.togglehq.com"
    end
  end
end

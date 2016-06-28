module Togglehq
  class Config
    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :host
    attr_accessor :auth_token

    def initialize
      @host = "http://localhost:3000"
    end
  end
end

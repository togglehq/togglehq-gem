module Togglehq
  class Config
    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :uri
    attr_accessor :log_requests

    def initialize
      @uri = "https://api.togglehq.com"
      @log_requests = false
    end
  end
end

require 'faraday'
require 'json'
require 'base64'

module Togglehq
  class Request
    attr_accessor :path, :data
    attr_reader :headers

    def initialize(path = "", params = {})
      @path = path
      @data = params
      @token = Togglehq.config.auth_token || request_auth_token

      @headers = {
        'Accept' => 'application/vnd.togglehq.com;version=1',
        'Authorization' => "Bearer #{@token}"
      }
    end

    def get!
      request(:get, path, data).data
    end

    def post!
      response = request(:post, path, data)
      JSON.parse(response.body)
    end

    def put!
      response = request(:put, path, data)
      JSON.parse(response.body)
    end

    def delete!
      response = request(:delete, path, data)
      JSON.parse(response.body)
    end

    private

    def api_url(path)
      "#{Togglehq.config.host}/api/#{path}"
    end

    def request(method, path, params, success_status = 200)
      conn = Faraday.new
      conn.headers = headers

      response = conn.send(method, api_url(path), params)
    end

    def request_auth_token
      basic = Base64.strict_encode64("#{Togglehq.config.client_id}:#{Togglehq.config.client_secret}")

      conn = Faraday.new
      conn.headers = { 'Authorization' => "Basic #{basic}" }

      response = conn.post("#{Togglehq.config.host}/oauth/token", {grant_type: "client_credentials"})

      Togglehq.config.auth_token = JSON.parse(response.body)["access_token"]
    end
  end
end

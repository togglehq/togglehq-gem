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
      @token = Togglehq.config.access_token || request_access_token

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
      "/api/#{path}"
    end

    def request(method, path, params, success_status = 200)
      conn = Togglehq.connection
      response = conn.send(method) do |req|
        req.url api_url(path)
        req.headers['Content-Type'] = 'application/json'
        req.headers.merge!(headers)
        req.body = params.to_json
      end
      response
    end

    def request_access_token
      basic = Base64.strict_encode64("#{Togglehq.config.client_id}:#{Togglehq.config.client_secret}")

      conn = Togglehq.connection
      response = conn.post do |req|
        req.url "/oauth/token"
        req.headers['Authorization'] = "Basic #{basic}"
        req.body = {grant_type: "client_credentials"}.to_json
      end
      response_body = JSON.parse(response.body)
      Togglehq.config.access_token = response.body["access_token"]
      Togglehq.config.refresh_token = response.body["refresh_token"]
    end
  end
end

require 'faraday'
require 'json'
require 'base64'

module Togglehq
  class Request

    V1 = "application/vnd.togglehq.com;version=1"
    ACCESS_TOKEN_KEY = "togglehq-api-access-token"

    attr_accessor :path, :params
    attr_reader :headers

    def initialize(path="", params={}, version=V1)
      @path = path
      @params = params
      @headers = {
        'Accept' => version,
      }
    end

    def get!
      request(:get, path, params)
    end

    def post!
      request(:post, path, params)
    end

    def put!
      request(:put, path, params)
    end

    def patch!
      request(:patch, path, params)
    end

    def delete!
      request(:delete, path, params)
    end


    private

    def request(method, path, params)
      ensure_togglehq_api_access_token
      conn = authenticated_togglehq_api_connection
      response = conn.send(method) do |req|
        req.url path
        req.headers['Content-Type'] = 'application/json'
        req.headers.merge!(headers)
        req.body = params.to_json
      end
      response
    end

    def togglehq_api_connection
      conn = Togglehq.connection
      basic = Base64.strict_encode64("#{Togglehq.config.client_id}:#{Togglehq.config.client_secret}")
      conn.headers.merge!({'Authorization' => "Basic #{basic}"})
      conn
    end

    def authenticated_togglehq_api_connection
      token = Togglehq.cache[ACCESS_TOKEN_KEY]
      conn = Togglehq.connection
      conn.headers.merge!({'Authorization' => "Bearer #{token["access_token"]}"})
      conn
    end

    def ensure_togglehq_api_access_token
      token = Togglehq.cache[ACCESS_TOKEN_KEY]
      if !token.nil?
        expires_at = Time.at(token["created_at"] + token["expires_in"])
        if expires_at <= Time.now
          get_new_access_token!
        end
      else
        get_new_access_token!
      end
    end

    def get_new_access_token!
      response = togglehq_api_connection.post do |req|
        req.url "/oauth/token"
        req.headers['Content-Type'] = 'application/json'
        req.body = {grant_type: "client_credentials", scope: "togglehq-lib"}.to_json
      end
      begin
        response_document = JSON.parse(response.body)
        if response_document.has_key?("error")
          process_api_error(response_document)
        else
          set_authenticated_oauth_token(response_document)
        end
      rescue JSON::ParserError
        raise "Fatal: unexpected response from ToggleHQ API: #{response.body}"
      end
    end

    def process_api_error(response_document)
      if response_document["error"] == "invalid_client"
        raise "Could not authenticate with ToggleHQ API: invalid client_id and/or client_secret."
      else
        raise "Unexpected error from ToggleHQ API: #{response_document["error_description"]}"
      end
    end

    def set_authenticated_oauth_token(response_document)
      Togglehq.cache[ACCESS_TOKEN_KEY] = response_document
    end
  end
end

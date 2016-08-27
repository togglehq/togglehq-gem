require 'faraday'
require 'json'
require 'base64'

module Togglehq
  class Request

    V1 = "application/vnd.togglehq.com;version=1"

    attr_accessor :path, :data
    attr_reader :headers

    def initialize(path="", params={}, version=V1)
      @path = path
      @data = params
      ensure_togglehq_api_access_token
      @token = Togglehq.cache["togglehq-api-access-token"]

      @headers = {
        'Accept' => version,
      }
    end

    def get!(version=V1)
      request(:get, path, data, version)
    end

    def post!(version=V1)
      request(:post, path, data, version)
    end

    def put!(version=V1)
      request(:put, path, data, version)
    end

    def delete!(version=V1)
      request(:delete, path, data, version)
    end


    private

    def api_url(path)
      "/#{path}"
    end

    def request(method, path, params, success_status = 200)
      ensure_togglehq_api_access_token
      conn = authenticated_togglehq_api_connection
      response = conn.send(method) do |req|
        req.url api_url(path)
        req.headers['Content-Type'] = 'application/json'
        req.headers.merge!(headers)
        req.body = params.to_json
      end
      response
    end

    def togglehq_api_connection
      conn = Togglehq.connection
      basic = Base64.strict_encode64("#{Togglehq.config.client_id}:#{Togglehq.config.client_secret}")
      conn.headers = { 'Authorization' => "Basic #{basic}" }
      conn
    end

    def authenticated_togglehq_api_connection
      token = Togglehq.cache["togglehq-api-access-token"]
      conn = togglehq_api_connection
      conn.headers.merge!('Authorization' => "Bearer #{token["access_token"]}")
      conn
    end

    def ensure_togglehq_api_access_token
      token = Togglehq.cache["togglehq-api-access-token"]
      if !token.nil?
        expires_at = Time.at(token["created_at"] + token["expires_in"])
        if expires_at <= Time.now
          token = togglehq_api_connection.post do |req|
            req.url "/oauth/token"
            req.headers['Content-Type'] = 'application/json'
            req.body = {grant_type: "refresh_token", refresh_token: token["refresh_token"], scope: "togglehq-lib"}.to_json
          end
          set_authenticated_oauth_token(token)
        end
      else
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
    end

    def process_api_error(response_document)
      if response_document["error"] == "invalid_client"
        raise "Could not authenticate with ToggleHQ API: invalid client_id and/or client_secret."
      else
        raise "Unexpected error from ToggleHQ API: #{response_document["error_description"]}"
      end
    end

    def set_authenticated_oauth_token(response_document)
      Togglehq.cache["togglehq-api-access-token"] = response_document
    end
  end
end

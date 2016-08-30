require 'spec_helper'

module Togglehq
  describe Request do
    let(:path) { "/test" }
    let(:params) { {"param1"=>"Jaime Meline", "param2"=>"Michael Render"} }
    let(:request) { Togglehq::Request.new(path, params) }

    context "#get!" do
      it "calls request with the given arguments" do
        expect(request).to receive(:request).with(:get, path, params)
        request.get!
      end
    end

    context "#post!" do
      it "calls request with the given arguments" do
        expect(request).to receive(:request).with(:post, path, params)
        request.post!
      end
    end

    context "#put!" do
      it "calls request with the given arguments" do
        expect(request).to receive(:request).with(:put, path, params)
        request.put!
      end
    end

    context "#patch!" do
      it "calls request with the given arguments" do
        expect(request).to receive(:request).with(:patch, path, params)
        request.patch!
      end
    end

    context "#delete!" do
      it "calls request with the given arguments" do
        expect(request).to receive(:request).with(:delete, path, params)
        request.delete!
      end
    end

    context "#request" do
      let(:mock_connection) { double("connection") }
      let(:mock_request) { double("request") }
      let(:mock_headers) { double("headers") }

      it "makes an authenticated request" do
        expect(request).to receive(:ensure_togglehq_api_access_token)
        expect(request).to receive(:authenticated_togglehq_api_connection).and_return(mock_connection)
        expect(mock_connection).to receive(:send).and_yield(mock_request)
        expect(mock_request).to receive(:url).with(path)
        expect(mock_request).to receive(:headers).twice.and_return(mock_headers)
        expect(mock_headers).to receive(:[]=).with("Content-Type", "application/json")
        expect(mock_headers).to receive(:merge!).with("Accept" => "application/vnd.togglehq.com;version=1")
        expect(mock_request).to receive(:body=).with(params.to_json)
        request.get!
      end
    end

    context "#togglehq_api_connection" do
      let(:mock_connection) { double("connection") }
      let(:mock_headers) { double("headers") }
      let(:basic_auth) { Base64.strict_encode64("#{Togglehq.config.client_id}:#{Togglehq.config.client_secret}") }

      it "sets the Authorization header for basic auth" do
        expect(Togglehq).to receive(:connection).and_return(mock_connection)
        expect(mock_connection).to receive(:headers).and_return(mock_headers)
        expect(mock_headers).to receive(:merge!).with("Authorization" => "Basic #{basic_auth}")
        request.send(:togglehq_api_connection)
      end
    end

    context "#authenticated_togglehq_api_connection" do
      let(:mock_connection) { double("connection") }
      let(:mock_headers) { double("headers") }
      let!(:token) { Togglehq.cache[Togglehq::Request::ACCESS_TOKEN_KEY] = {"access_token"=>"foo"} }

      it "sets the bearer token in the Authorization header" do
        expect(Togglehq).to receive(:connection).and_return(mock_connection)
        expect(mock_connection).to receive(:headers).and_return(mock_headers)
        expect(mock_headers).to receive(:merge!).with("Authorization" => "Bearer #{Togglehq.cache[Togglehq::Request::ACCESS_TOKEN_KEY]["access_token"]}")
        request.send(:authenticated_togglehq_api_connection)
      end
    end

    context "#ensure_togglehq_api_access_token" do
      let(:mock_connection) { double("connection") }
      let(:mock_request) { double("request") }
      let(:mock_headers) { double("headers") }

      context "cached token" do
        context "token expired" do
          let(:expired_token) { {"access_token"=>"foo", "expires_in" => 1, "created_at" => Date.new(2016, 1, 1).to_time.to_i} }
          let!(:token) { Togglehq.cache[Togglehq::Request::ACCESS_TOKEN_KEY] = expired_token }
          let(:mock_response) { double("response") }
          let(:success_response) { {"access_token" => "foo", "created_at" => Time.now.to_i, "expires_in" => 123456} }

          it "gets a new access token" do
            expect(request).to receive(:togglehq_api_connection).and_return(mock_connection)
            expect(mock_connection).to receive(:post).and_yield(mock_request).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(success_response.to_json)
            expect(mock_request).to receive(:url).with("/oauth/token")
            expect(mock_request).to receive(:headers).and_return(mock_headers)
            expect(mock_headers).to receive(:[]=).with("Content-Type", "application/json")
            expect(mock_request).to receive(:body=).with({grant_type: "client_credentials", scope: "togglehq-lib"}.to_json)
            expect(request).to receive(:set_authenticated_oauth_token)
            request.send(:ensure_togglehq_api_access_token)
          end
        end
      end

      context "no cached token" do
        let(:mock_response) { double("response") }

        before :each do
          Togglehq.cache[Togglehq::Request::ACCESS_TOKEN_KEY] = nil
        end

        context "success response" do
          let(:success_response) { {"access_token" => "foo", "created_at" => Time.now.to_i, "expires_in" => 123456} }

          it "gets a new access token" do
            expect(request).to receive(:togglehq_api_connection).and_return(mock_connection)
            expect(mock_connection).to receive(:post).and_yield(mock_request).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(success_response.to_json)
            expect(mock_request).to receive(:url).with("/oauth/token")
            expect(mock_request).to receive(:headers).and_return(mock_headers)
            expect(mock_headers).to receive(:[]=).with("Content-Type", "application/json")
            expect(mock_request).to receive(:body=).with({grant_type: "client_credentials", scope: "togglehq-lib"}.to_json)
            expect(request).to receive(:set_authenticated_oauth_token)
            request.send(:ensure_togglehq_api_access_token)
          end
        end

        context "not a valid JSON response" do
          let(:success_response) { "<html></html>" }

          it "raises an error" do
            expect(request).to receive(:togglehq_api_connection).and_return(mock_connection)
            expect(mock_connection).to receive(:post).and_yield(mock_request).and_return(mock_response)
            expect(mock_response).to receive(:body).twice.and_return(success_response)
            expect(mock_request).to receive(:url).with("/oauth/token")
            expect(mock_request).to receive(:headers).and_return(mock_headers)
            expect(mock_headers).to receive(:[]=).with("Content-Type", "application/json")
            expect(mock_request).to receive(:body=).with({grant_type: "client_credentials", scope: "togglehq-lib"}.to_json)
            expect {request.send(:ensure_togglehq_api_access_token)}.to raise_error(RuntimeError, "Fatal: unexpected response from ToggleHQ API: <html></html>")
          end
        end

        context "error response" do
          context "invalid_client" do
            let(:error_response) { {"error" => "invalid_client"} }

            it "raises an error" do
              expect(request).to receive(:togglehq_api_connection).and_return(mock_connection)
              expect(mock_connection).to receive(:post).and_yield(mock_request).and_return(mock_response)
              expect(mock_response).to receive(:body).and_return(error_response.to_json)
              expect(mock_request).to receive(:url).with("/oauth/token")
              expect(mock_request).to receive(:headers).and_return(mock_headers)
              expect(mock_headers).to receive(:[]=).with("Content-Type", "application/json")
              expect(mock_request).to receive(:body=).with({grant_type: "client_credentials", scope: "togglehq-lib"}.to_json)
              expect {request.send(:ensure_togglehq_api_access_token)}.to raise_error(RuntimeError, "Could not authenticate with ToggleHQ API: invalid client_id and/or client_secret.")
            end
          end

          context "unexpected error" do
            let(:error_response) { {"error" => "something bad happened", "error_description" => "oh no"} }

            it "raises an error" do
              expect(request).to receive(:togglehq_api_connection).and_return(mock_connection)
              expect(mock_connection).to receive(:post).and_yield(mock_request).and_return(mock_response)
              expect(mock_response).to receive(:body).and_return(error_response.to_json)
              expect(mock_request).to receive(:url).with("/oauth/token")
              expect(mock_request).to receive(:headers).and_return(mock_headers)
              expect(mock_headers).to receive(:[]=).with("Content-Type", "application/json")
              expect(mock_request).to receive(:body=).with({grant_type: "client_credentials", scope: "togglehq-lib"}.to_json)
              expect {request.send(:ensure_togglehq_api_access_token)}.to raise_error(RuntimeError)#, "Unexpected error from ToggleHQ API: on no")
            end
          end
        end
      end
    end
  end
end

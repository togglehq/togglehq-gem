require 'spec_helper'

module Togglehq
  module Notify
    describe UserSettings do
      let(:user) do
        user = Togglehq::User.new(identifier: "abcdef123456")
        user
      end
      let(:user_settings) do
        user_settings = Togglehq::Notify::UserSettings.new(user)
        user_settings
      end
      let(:settings_json) { [{"name":"Push Notifications","key":"push_notification","settings":[{"name":"Friend Request","key":"friend_request","default":true,"enabled":true}]}] }

      context "#groups" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }

        it "memoizes the response from the ToggleHQ API" do
          expect(Togglehq::Request).to receive(:new).with("/settings", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
          expect(mock_request).to receive(:get!).and_return(mock_response)
          expect(mock_response).to receive(:body).and_return(settings_json.to_json)
          expect(mock_response).to receive(:status).and_return(200)
          groups = user_settings.groups

          expect(Togglehq::Request).not_to receive(:new).with("/settings", {"user" => {"identifier" => user.identifier}})
          groups = user_settings.groups
        end

        context "response status 200" do
          it "returns a Togglehq::Notify::Settings object" do
            expect(Togglehq::Request).to receive(:new).with("/settings", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(settings_json.to_json)
            expect(mock_response).to receive(:status).and_return(200)
            groups = user_settings.groups
            expect(groups).not_to eq(nil)
            expect(groups).to eq(JSON.parse(settings_json.to_json))
          end
        end

        context "response status 404" do
          it "raises a RuntimeError with a message that the user was not found" do
            expect(Togglehq::Request).to receive(:new).with("/settings", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect {user_settings.groups}.to raise_error(RuntimeError, "user not found")
          end
        end

        context "unexpected status" do
          it "raises a RuntimeError" do
            expect(Togglehq::Request).to receive(:new).with("/settings", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            allow(mock_response).to receive(:status).and_return(500)
            expect {user_settings.groups}.to raise_error(RuntimeError, "Unexpected error getting app settings")
          end
        end
      end

      context "#enable_setting!" do
        context "404 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"parameter" => "group", "message" => "the requested group was not found"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(not_found_response)
            expect {user_settings.enable_setting!("foo", "bar")}.to raise_error(RuntimeError, "the requested group was not found")
          end
        end

        context "200 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "push_notification", "setting" => "friend_request"} }
          let(:not_found_response) { {"message" => "setting enabled"}.to_json }

          it "sets enabled to true on the given setting" do
            expect(Togglehq::Request).to receive(:new).with("/settings", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(settings_json.to_json)
            expect(mock_response).to receive(:status).and_return(200)
            groups = user_settings.groups
            groups[0]["settings"][0]["enabled"] = false
            expect(groups[0]["settings"][0]["enabled"]).to eq(false)

            expect(Togglehq::Request).to receive(:new).with("/settings/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            user_settings.enable_setting!("push_notification", "friend_request")
            expect(groups[0]["settings"][0]["enabled"]).to eq(true)
          end

          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/settings/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            expect(user_settings.enable_setting!("push_notification", "friend_request")).to eq(true)
          end
        end

        context "unexpected response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"message" => "something bad has happened"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(500)
            expect {user_settings.enable_setting!("foo", "bar")}.to raise_error(RuntimeError, "unexpected error enabling setting")
          end
        end
      end

      context "#disable_setting!" do
        context "404 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"parameter" => "group", "message" => "the requested group was not found"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(not_found_response)
            expect {user_settings.disable_setting!("foo", "bar")}.to raise_error(RuntimeError, "the requested group was not found")
          end
        end

        context "200 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "push_notification", "setting" => "friend_request"} }
          let(:not_found_response) { {"message" => "setting disabled"}.to_json }

          it "sets enabled to false on the given setting" do
            expect(Togglehq::Request).to receive(:new).with("/settings", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(settings_json.to_json)
            expect(mock_response).to receive(:status).and_return(200)
            groups = user_settings.groups
            groups[0]["settings"][0]["enabled"] = true
            expect(groups[0]["settings"][0]["enabled"]).to eq(true)

            expect(Togglehq::Request).to receive(:new).with("/settings/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            user_settings.disable_setting!("push_notification", "friend_request")
            expect(groups[0]["settings"][0]["enabled"]).to eq(false)
          end

          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/settings/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            expect(user_settings.disable_setting!("push_notification", "friend_request")).to eq(true)
          end
        end

        context "unexpected response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"message" => "something bad has happened"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(500)
            expect {user_settings.disable_setting!("foo", "bar")}.to raise_error(RuntimeError, "unexpected error disabling setting")
          end
        end
      end
    end
  end
end

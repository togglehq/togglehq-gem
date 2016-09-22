require 'spec_helper'

module Togglehq
  module Notify
    describe UserPreferences do
      let(:user) do
        user = Togglehq::User.new(identifier: "abcdef123456")
        user
      end
      let(:user_preferences) do
        user_preferences = Togglehq::Notify::UserPreferences.new(user)
        user_preferences
      end
      let(:preferences_json) { [{"name":"Push Notifications","key":"push_notification","preferences":[{"name":"Friend Request","key":"friend_request","default":true,"enabled":true}]}] }

      context "#categories" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }

        it "memoizes the response from the ToggleHQ API" do
          expect(Togglehq::Request).to receive(:new).with("/preferences", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
          expect(mock_request).to receive(:get!).and_return(mock_response)
          expect(mock_response).to receive(:body).and_return(preferences_json.to_json)
          expect(mock_response).to receive(:status).and_return(200)
          categories = user_preferences.categories

          expect(Togglehq::Request).not_to receive(:new).with("/preferences", {"user" => {"identifier" => user.identifier}})
          categories = user_preferences.categories
        end

        context "response status 200" do
          it "returns a Togglehq::Notify::Preferences object" do
            expect(Togglehq::Request).to receive(:new).with("/preferences", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(preferences_json.to_json)
            expect(mock_response).to receive(:status).and_return(200)
            categories = user_preferences.categories
            expect(categories).not_to eq(nil)
            expect(categories).to eq(JSON.parse(preferences_json.to_json))
          end
        end

        context "response status 404" do
          it "raises a RuntimeError with a message that the user was not found" do
            expect(Togglehq::Request).to receive(:new).with("/preferences", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect {user_preferences.categories}.to raise_error(RuntimeError, "user not found")
          end
        end

        context "unexpected status" do
          it "raises a RuntimeError" do
            expect(Togglehq::Request).to receive(:new).with("/preferences", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            allow(mock_response).to receive(:status).and_return(500)
            expect {user_preferences.categories}.to raise_error(RuntimeError, "Unexpected error getting user preferences")
          end
        end
      end

      context "#enable_preference!" do
        context "404 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "category" => "foo", "preference" => "bar"} }
          let(:not_found_response) { {"parameter" => "category", "message" => "the requested category was not found"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/preferences/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(not_found_response)
            expect {user_preferences.enable_preference!("foo", "bar")}.to raise_error(RuntimeError, "the requested category was not found")
          end
        end

        context "200 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "category" => "push_notification", "preference" => "friend_request"} }
          let(:not_found_response) { {"message" => "preference enabled"}.to_json }

          it "sets enabled to true on the given preference" do
            expect(Togglehq::Request).to receive(:new).with("/preferences", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(preferences_json.to_json)
            expect(mock_response).to receive(:status).and_return(200)
            categories = user_preferences.categories
            categories[0]["preferences"][0]["enabled"] = false
            expect(categories[0]["preferences"][0]["enabled"]).to eq(false)

            expect(Togglehq::Request).to receive(:new).with("/preferences/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            user_preferences.enable_preference!("push_notification", "friend_request")
            expect(categories[0]["preferences"][0]["enabled"]).to eq(true)
          end

          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/preferences/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            expect(user_preferences.enable_preference!("push_notification", "friend_request")).to eq(true)
          end
        end

        context "unexpected response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "category" => "foo", "preference" => "bar"} }
          let(:not_found_response) { {"message" => "something bad has happened"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/preferences/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(500)
            expect {user_preferences.enable_preference!("foo", "bar")}.to raise_error(RuntimeError, "unexpected error enabling preference")
          end
        end
      end

      context "#disable_preference!" do
        context "404 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "category" => "foo", "preference" => "bar"} }
          let(:not_found_response) { {"parameter" => "category", "message" => "the requested category was not found"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/preferences/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(not_found_response)
            expect {user_preferences.disable_preference!("foo", "bar")}.to raise_error(RuntimeError, "the requested category was not found")
          end
        end

        context "200 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "category" => "push_notification", "preference" => "friend_request"} }
          let(:not_found_response) { {"parameter" => "category", "message" => "the requested category was not found"}.to_json }

          it "sets enabled to false on the given preference" do
            expect(Togglehq::Request).to receive(:new).with("/preferences", {"user" => {"identifier" => user.identifier}}).and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(preferences_json.to_json)
            expect(mock_response).to receive(:status).and_return(200)
            categories = user_preferences.categories
            categories[0]["preferences"][0]["enabled"] = true
            expect(categories[0]["preferences"][0]["enabled"]).to eq(true)

            expect(Togglehq::Request).to receive(:new).with("/preferences/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            user_preferences.disable_preference!("push_notification", "friend_request")
            expect(categories[0]["preferences"][0]["enabled"]).to eq(false)
          end

          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/preferences/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            expect(user_preferences.disable_preference!("push_notification", "friend_request")).to eq(true)
          end
        end

        context "unexpected response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "category" => "foo", "preference" => "bar"} }
          let(:not_found_response) { {"message" => "something bad has happened"}.to_json }

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/preferences/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(500)
            expect {user_preferences.disable_preference!("foo", "bar")}.to raise_error(RuntimeError, "unexpected error disabling preference")
          end
        end
      end
    end
  end
end

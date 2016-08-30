require 'spec_helper'

module Togglehq
  module Notify
    describe User do

      context "#initialize" do
        it "initializes from supported params" do
          user = User.new(identifier: "8sdfjlksdjhf", settings: [{name: "Test", key: "test"}])
          expect(user.identifier).to eq("8sdfjlksdjhf")
          expect(user.settings).to eq([{name: "Test", key: "test"}])
        end
      end

      context ".find_by_identifier" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:success_response) do
          {"identifier" => "foo",
           "settings" => [{"name" => "Push Notifications",
                           "key" => "push_notification",
                           "settings" => [{"name" => "Friend Request", "key" => "friend_request", "default" => true, "enabled" => true}]
                          }]}.to_json
        end

        it "makes a get request to /users/:identifier" do
          expect(Togglehq::Request).to receive(:new).with("/users/foo").and_return(mock_request)
          expect(mock_request).to receive(:get!).and_return(mock_response)
          allow(mock_response).to receive(:status).and_return(404)
          Togglehq::Notify::User.find_by_identifier("foo")
        end

        context "response status 404" do
          it "returns nil" do
            expect(Togglehq::Request).to receive(:new).with("/users/foo").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            allow(mock_response).to receive(:status).and_return(404)
            expect(Togglehq::Notify::User.find_by_identifier("foo")).to eq(nil)
          end
        end

        context "response status 200" do
          it "returns a Togglehq::Notify::User object" do
            expect(Togglehq::Request).to receive(:new).with("/users/foo").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(success_response)
            allow(mock_response).to receive(:status).and_return(200)
            user = Togglehq::Notify::User.find_by_identifier("foo")
            expect(user).not_to eq(nil)
            expect(user).to be_a(Togglehq::Notify::User)
            expect(user.identifier).to eq("foo")
            expect(user.settings).to eq([{"name" => "Push Notifications", "key" => "push_notification",
                                          "settings" => [{"name" => "Friend Request", "key" => "friend_request", "default" => true, "enabled" => true}]}])
          end
        end

        context "unexpected status" do
          it "raises a RuntimeError" do
            expect(Togglehq::Request).to receive(:new).with("/users/foo").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            allow(mock_response).to receive(:status).and_return(500)
            expect {Togglehq::Notify::User.find_by_identifier("foo")}.to raise_error(RuntimeError, "Unexpected error finding user")
          end
        end
      end

      context ".find_by_identifier!" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }

        context "user not found" do
          it "raises a RuntimeError" do
            expect(Togglehq::Request).to receive(:new).with("/users/foo").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            allow(mock_response).to receive(:status).and_return(404)
            expect {Togglehq::Notify::User.find_by_identifier!("foo")}.to raise_error(RuntimeError, "Could not find user with identifier foo")
          end
        end
      end

      context "#save" do
        context "successful response" do
          context "user does not exist" do
            let(:mock_request) { double("request") }
            let(:mock_response) { double("response") }
            let(:saved_response) { {"message" => "user added successfully"}.to_json }

            it "saves the user" do
              expect(Togglehq::Request).to receive(:new).with("/users", {"user" => {"identifier" => "abcdef123456"}}).and_return(mock_request)
              expect(mock_request).to receive(:post!).and_return(mock_response)
              expect(mock_response).to receive(:status).and_return(200)
              expect(mock_response).to receive(:body).and_return(saved_response)
              user = Togglehq::Notify::User.new
              user.identifier = "abcdef123456"
              expect(user.save).to eq(true)
            end
          end

          context "existing user" do
            let(:mock_request) { double("request") }
            let(:mock_response) { double("response") }
            let(:saved_response) { {"message" => "user already exists"}.to_json }
            let(:existing_user) { Togglehq::Notify::User.new }

            it "saves the user" do
              expect(Togglehq::Request).to receive(:new).with("/users", {"user" => {"identifier" => "abcdef123456"}}).and_return(mock_request)
              expect(mock_request).to receive(:post!).and_return(mock_response)
              expect(mock_response).to receive(:status).and_return(200)
              expect(mock_response).to receive(:body).and_return(saved_response)
              expect(Togglehq::Notify::User).to receive(:find_by_identifier).with("abcdef123456").and_return(existing_user)
              user = Togglehq::Notify::User.new
              user.identifier = "abcdef123456"
              user.save
            end
          end
        end

        context "unsuccessful response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:saved_response) { {"message" => "user added successfully"}.to_json }

          it "raises a RuntimeError" do
            expect(Togglehq::Request).to receive(:new).with("/users", {"user" => {"identifier" => "abcdef123456"}}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(500)
            user = Togglehq::Notify::User.new
            user.identifier = "abcdef123456"
            expect {user.save}.to raise_error(RuntimeError, "unexpected error saving user")
          end
        end
      end

      context "#enable_setting!" do
        context "404 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"parameter" => "group", "message" => "the requested group was not found"}.to_json }
          let(:user) do
            user = Togglehq::Notify::User.new
            user.identifier = "abcdef123456"
            user
          end

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(not_found_response)
            expect {user.enable_setting!("foo", "bar")}.to raise_error(RuntimeError, "the requested group was not found")
          end
        end

        context "200 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"message" => "setting enabled"}.to_json }
          let(:user) do
            user = Togglehq::Notify::User.new
            user.identifier = "abcdef123456"
            user
          end

          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/settings/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            expect(user.enable_setting!("foo", "bar")).to eq(true)
          end
        end

        context "unexpected response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"message" => "something bad has happened"}.to_json }
          let(:user) do
            user = Togglehq::Notify::User.new
            user.identifier = "abcdef123456"
            user
          end

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/enable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(500)
            expect {user.enable_setting!("foo", "bar")}.to raise_error(RuntimeError, "unexpected error enabling setting")
          end
        end
      end

      context "#disable_setting!" do
        context "404 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"parameter" => "group", "message" => "the requested group was not found"}.to_json }
          let(:user) do
            user = Togglehq::Notify::User.new
            user.identifier = "abcdef123456"
            user
          end

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(not_found_response)
            expect {user.disable_setting!("foo", "bar")}.to raise_error(RuntimeError, "the requested group was not found")
          end
        end

        context "200 response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"message" => "setting disabled"}.to_json }
          let(:user) do
            user = Togglehq::Notify::User.new
            user.identifier = "abcdef123456"
            user
          end

          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/settings/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(200)
            expect(user.disable_setting!("foo", "bar")).to eq(true)
          end
        end

        context "unexpected response" do
          let(:mock_request) { double("request") }
          let(:mock_response) { double("response") }
          let(:request) { {"user" => {"identifier" => "abcdef123456"}, "group" => "foo", "setting" => "bar"} }
          let(:not_found_response) { {"message" => "something bad has happened"}.to_json }
          let(:user) do
            user = Togglehq::Notify::User.new
            user.identifier = "abcdef123456"
            user
          end

          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/settings/disable", request).and_return(mock_request)
            expect(mock_request).to receive(:patch!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(500)
            expect {user.disable_setting!("foo", "bar")}.to raise_error(RuntimeError, "unexpected error disabling setting")
          end
        end
      end
    end
  end
end

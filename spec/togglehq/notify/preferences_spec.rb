require 'spec_helper'
require 'json'

module Togglehq
  module Notify
    describe Preferences do
      let(:preferences_json) { [{"name":"Push Notifications","key":"push_notification","preferences":[{"name":"Friend Request","key":"friend_request","default":true}]}] }

      context "#initialize" do
        it "initializes from supported params" do
          preferences = Preferences.new(categories: preferences_json)
          expect(preferences.categories).to eq(preferences_json)
        end
      end

      context ".all" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }

        context "response status 200" do
          it "returns a Togglehq::Notify::Preferences object" do
            expect(Togglehq::Request).to receive(:new).with("/preferences").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(preferences_json.to_json)
            allow(mock_response).to receive(:status).and_return(200)
            preferences = Togglehq::Notify::Preferences.all
            expect(preferences).not_to eq(nil)
            expect(preferences).to be_a(Togglehq::Notify::Preferences)
            expect(preferences.categories).to eq(JSON.parse(preferences_json.to_json))
          end
        end

        context "unexpected status" do
          it "raises a RuntimeError" do
            expect(Togglehq::Request).to receive(:new).with("/preferences").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            allow(mock_response).to receive(:status).and_return(500)
            expect {Togglehq::Notify::Preferences.all}.to raise_error(RuntimeError, "Unexpected error getting app preferences")
          end
        end
      end
    end
  end
end

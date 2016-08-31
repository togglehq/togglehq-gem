require 'spec_helper'
require 'json'

module Togglehq
  module Notify
    describe Settings do
      let(:settings_json) { [{"name":"Push Notifications","key":"push_notification","settings":[{"name":"Friend Request","key":"friend_request","default":true}]}] }

      context "#initialize" do
        it "initializes from supported params" do
          settings = Settings.new(groups: settings_json)
          expect(settings.groups).to eq(settings_json)
        end
      end

      context ".all" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }

        context "response status 200" do
          it "returns a Togglehq::Notify::Settings object" do
            expect(Togglehq::Request).to receive(:new).with("/settings").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            expect(mock_response).to receive(:body).and_return(settings_json.to_json)
            allow(mock_response).to receive(:status).and_return(200)
            settings = Togglehq::Notify::Settings.all
            expect(settings).not_to eq(nil)
            expect(settings).to be_a(Togglehq::Notify::Settings)
            expect(settings.groups).to eq(JSON.parse(settings_json.to_json))
          end
        end

        context "unexpected status" do
          it "raises a RuntimeError" do
            expect(Togglehq::Request).to receive(:new).with("/settings").and_return(mock_request)
            expect(mock_request).to receive(:get!).and_return(mock_response)
            allow(mock_response).to receive(:status).and_return(500)
            expect {Togglehq::Notify::Settings.all}.to raise_error(RuntimeError, "Unexpected error getting app settings")
          end
        end
      end
    end
  end
end

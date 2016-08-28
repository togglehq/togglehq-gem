require 'spec_helper'

module Togglehq
  describe Config do
    describe "#client_id" do
      it "defaults to nil" do
        config = Config.new
        expect(config.client_id).to eq(nil)
      end

      it "can set a value for client_id" do
        config = Config.new
        config.client_id = 12345
        expect(config.client_id).to eq(12345)
      end
    end

    describe "#client_secret" do
      it "defaults to nil" do
        config = Config.new
        expect(config.client_secret).to eq(nil)
      end

      it "can set a value for client_secret" do
        config = Config.new
        config.client_secret = 34567
        expect(config.client_secret).to eq(34567)
      end
    end

    describe "#uri" do
      it "defaults to https://api.togglehq.com" do
        config = Config.new
        expect(config.uri).to eq("https://api.togglehq.com")
      end

      it "can set a value for uri" do
        config = Config.new
        config.uri = "http://localhost:3003"
        expect(config.uri).to eq("http://localhost:3003")
      end
    end

    describe "#log_requests" do
      it "defaults to false" do
        config = Config.new
        expect(config.log_requests).to eq(false)
      end

      it "can set a value for log_requests" do
        config = Config.new
        config.log_requests = true
        expect(config.log_requests).to eq(true)
      end
    end
  end
end

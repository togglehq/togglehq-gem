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

    describe "#access_token" do
      it "defaults to nil" do
        config = Config.new
        expect(config.access_token).to eq(nil)
      end

      it "can set a value for access_token" do
        config = Config.new
        config.access_token = "qwerty"
        expect(config.access_token).to eq("qwerty")
      end
    end

    describe "#refresh_token" do
      it "defaults to nil" do
        config = Config.new
        expect(config.refresh_token).to eq(nil)
      end

      it "can set a value for refresh_token" do
        config = Config.new
        config.refresh_token = "qwerty"
        expect(config.refresh_token).to eq("qwerty")
      end
    end
  end
end

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

    describe "#host" do
      it "defaults to http://localhost:3000" do
        config = Config.new
        expect(config.host).to eq("http://localhost:3000")
      end

      it "can set a value for host" do
        config = Config.new
        config.host = "http://localhost:3003"
        expect(config.host).to eq("http://localhost:3003")
      end
    end

    describe "#auth_token" do
      it "defaults to nil" do
        config = Config.new
        expect(config.auth_token).to eq(nil)
      end

      it "can set a value for auth_token" do
        config = Config.new
        config.host = "qwerty"
        expect(config.host).to eq("qwerty")
      end
    end
  end
end

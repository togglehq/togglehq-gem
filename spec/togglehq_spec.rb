require 'spec_helper'

describe Togglehq do
  it 'has a version number' do
    expect(Togglehq::VERSION).not_to be nil
  end

  describe ".reset" do
    before :each do
      Togglehq.configure do |config|
        config.client_id = 12345
      end
    end

    it "resets the config" do
      Togglehq.reset
      config = Togglehq.config
      expect(config.client_id).to eq(nil)
    end
  end

  describe "#configure" do
    before do
      Togglehq.configure do |config|
        config.client_id = 12345
        config.client_secret = 67890
        config.uri = "http://localhost:3003"
      end
    end

    it "sets the client_id correctly" do
      expect(Togglehq.config.client_id).to eq(12345)
    end

    it "sets the client_secret correctly" do
      expect(Togglehq.config.client_secret).to eq(67890)
    end

    it "sets the uri correctly" do
      expect(Togglehq.config.uri).to eq("http://localhost:3003")
    end

    after :each do
      Togglehq.reset
    end
  end
end

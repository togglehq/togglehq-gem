require 'spec_helper'

describe Togglehq do
  it 'has a version number' do
    expect(Togglehq::VERSION).not_to be nil
  end

  describe ".config" do
    it "exposes a Togglehq::Config object" do
      expect(Togglehq.config.class).to eq(Togglehq::Config)
    end
  end

  describe ".cache" do
    it "exposes a Hash to store objects" do
      expect(Togglehq.cache.class).to eq(Hash)
    end
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

  describe ".logger" do
    it "exposes a Logger object" do
      expect(Togglehq.logger.class).to eq(Logger)
    end
  end

  describe ".configure" do
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

  describe ".connection" do
    let(:mock_faraday) { double("Faraday") }

    it "creates a configured Faraday connection" do
      expect(Faraday).to receive(:new).with(:url => Togglehq.config.uri).and_yield(mock_faraday)
      expect(mock_faraday).to receive(:adapter).with(:net_http_persistent)
      expect(mock_faraday).not_to receive(:response)
      Togglehq.connection
    end

    it "configures the Faraday logger if config.log_requests is true" do
      Togglehq.config.log_requests = true
      expect(Faraday).to receive(:new).with(:url => Togglehq.config.uri).and_yield(mock_faraday)
      allow(mock_faraday).to receive(:adapter)
      expect(mock_faraday).to receive(:response).with(:logger, Togglehq.logger, bodies: true)
      Togglehq.connection
    end
  end
end

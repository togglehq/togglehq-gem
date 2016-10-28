require 'spec_helper'

module Togglehq
  describe Device do

    context "#initialize" do
      it "initializes from supported params" do
        device = Device.new(os:"ios", os_version:10.0, manufacturer:"Apple", model:"iPhone")
        expect(device.os).to eq("ios")
        expect(device.os_version).to eq(10.0)
        expect(device.manufacturer).to eq("Apple")
        expect(device.model).to eq("iPhone")
      end
    end

    context "#enable!" do
      let(:device) { Device.new(:uuid => "abcdef123456")}

      context "404 response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456", "token" => "123456789"} }}
        let(:not_found_response) { {"parameter" => "device", "message" => "the requested device was not found"}.to_json }

        it "raises an error" do
          expect(Togglehq::Request).to receive(:new).with("/devices/enable", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).twice.and_return(404)
          expect(mock_response).to receive(:body).and_return(not_found_response)
          expect {device.enable!("123456789")}.to raise_error(RuntimeError, "the requested device was not found")
        end
      end

      context "200 response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456", "token" => "123456789"} }}
        let(:response) { {"message" => "device enabled"}.to_json }

        it "returns true" do
          expect(Togglehq::Request).to receive(:new).with("/devices/enable", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).and_return(200)
          expect(device.enable!("123456789")).to eq(true)
        end
      end

      context "unexpected response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456", "token" => "123456789"} }}
        let(:response) { {"message" => "oops.. something happened"}.to_json }

        it "returns true" do
          expect(Togglehq::Request).to receive(:new).with("/devices/enable", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).twice.and_return(500)
          expect {device.enable!("123456789")}.to raise_error(RuntimeError, "unexpected error enabling the device")
        end
      end
    end

    context "#assign!" do
      let(:device) { Device.new(:uuid => "abcdef123456")}

      context "404 response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456"}, "user" => {"identifier" => "abcdef0123456789"} }}
        let(:not_found_response) { {"parameter" => "device", "message" => "the requested device was not found"}.to_json }

        it "raises an error" do
          expect(Togglehq::Request).to receive(:new).with("/devices/assign", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).twice.and_return(404)
          expect(mock_response).to receive(:body).and_return(not_found_response)
          expect {device.assign!("abcdef0123456789")}.to raise_error(RuntimeError, "the requested device was not found")
        end
      end

      context "200 response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456"}, "user" => {"identifier" => "abcdef0123456789"} }}
        let(:response) { {"message" => "device assigned"}.to_json }

        it "returns true" do
          expect(Togglehq::Request).to receive(:new).with("/devices/assign", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).and_return(200)
          expect(device.assign!("abcdef0123456789")).to eq(true)
        end
      end

      context "unexpected response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456"}, "user" => {"identifier" => "abcdef0123456789"} }}
        let(:response) { {"message" => "oops.. something happened"}.to_json }

        it "returns true" do
          expect(Togglehq::Request).to receive(:new).with("/devices/assign", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).twice.and_return(500)
          expect {device.assign!("abcdef0123456789")}.to raise_error(RuntimeError, "unexpected error assigning the device")
        end
      end
    end

    context "#unassign!" do
      let(:device) { Device.new(:uuid => "abcdef123456")}

      context "404 response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456"} }}
        let(:not_found_response) { {"parameter" => "device", "message" => "the requested device was not found"}.to_json }

        it "raises an error" do
          expect(Togglehq::Request).to receive(:new).with("/devices/unassign", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).twice.and_return(404)
          expect(mock_response).to receive(:body).and_return(not_found_response)
          expect {device.unassign!}.to raise_error(RuntimeError, "the requested device was not found")
        end
      end

      context "200 response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456"} }}
        let(:response) { {"message" => "device unassigned"}.to_json }

        it "returns true" do
          expect(Togglehq::Request).to receive(:new).with("/devices/unassign", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).and_return(200)
          expect(device.unassign!).to eq(true)
        end
      end

      context "unexpected response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:request) { {"device" => {"uuid" => "abcdef123456"} }}
        let(:response) { {"message" => "oops.. something happened"}.to_json }

        it "returns true" do
          expect(Togglehq::Request).to receive(:new).with("/devices/unassign", request).and_return(mock_request)
          expect(mock_request).to receive(:patch!).and_return(mock_response)
          expect(mock_response).to receive(:status).twice.and_return(500)
          expect {device.unassign!}.to raise_error(RuntimeError, "unexpected error unassigning the device")
        end
      end
    end

    context "#save" do
      context "successful response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:saved_response) {
          { :message => "device created successfully",
            :device => {
              :os => "ios",
              :uuid => "abcd1234",
              :os_version => 10.0,
              :manufacturer => "Apple",
              :model => "iPhone"
            }
          }.to_json
        }

        it "saves the device" do
          expect(Togglehq::Request).to receive(:new).with("/devices", {"device" => {"os" => "ios", "os_version" => 10.0, "manufacturer" => "Apple", "model" => "iPhone"}}).and_return(mock_request)
          expect(mock_request).to receive(:post!).and_return(mock_response)
          expect(mock_response).to receive(:status).and_return(200)
          expect(mock_response).to receive(:body).and_return(saved_response)
          device = Togglehq::Device.new
          device.os = "ios"
          device.os_version = 10.0
          device.manufacturer = "Apple"
          device.model = "iPhone"
          expect(device.save).to eq(true)
          expect(device.uuid).to eq("abcd1234")
        end
      end

      context "unsuccessful response" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:saved_response) {
          { :message => "device created successfully",
            :device => {
              :os => "ios",
              :uuid => "abcd1234",
              :os_version => 10.0,
              :manufacturer => "Apple",
              :model => "iPhone"
            }
          }.to_json
        }

        it "raises a RuntimeError" do
          expect(Togglehq::Request).to receive(:new).with("/devices", {"device" => {"os" => "ios", "os_version" => 10.0, "manufacturer" => "Apple", "model" => "iPhone"}}).and_return(mock_request)
          expect(mock_request).to receive(:post!).and_return(mock_response)
          expect(mock_response).to receive(:status).and_return(500)
          device = Togglehq::Device.new
          device.os = "ios"
          device.os_version = 10.0
          device.manufacturer = "Apple"
          device.model = "iPhone"
          expect {device.save}.to raise_error(RuntimeError, "unexpected error saving the device")
        end
      end
    end
  end
end

require 'spec_helper'

module Togglehq
  module Notify
    describe Notification do
      context "#initialize" do
        it "initializes from supported params" do
          notification = Notification.new(group_key: "foo", setting_key: "bar", message: "hi mom")
          expect(notification.group_key).to eq("foo")
          expect(notification.setting_key).to eq("bar")
          expect(notification.message).to eq("hi mom")
        end
      end

      context "#send" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:notification) { Notification.new(group_key: "foo", setting_key: "bar", message: "hi mom") }
        let(:error_response) { {parameter: "foo", message: "something bad has happened"}.to_json }
        let(:user) { User.new(identifier: "abc123") }

        context "403 response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :user => "abc123"}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(403)
            expect {notification.send(user)}.to raise_error(RuntimeError, "Access denied. You must use your Master OAuth client_id and client_secret to send push notifications.")
          end
        end

        context "404 response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :user => "abc123"}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(error_response)
            expect {notification.send(user)}.to raise_error(RuntimeError, "something bad has happened")
          end
        end

        context "422 response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :user => "abc123"}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).exactly(3).times.and_return(422)
            expect(mock_response).to receive(:body).and_return(error_response)
            expect {notification.send(user)}.to raise_error(RuntimeError, "something bad has happened")
          end
        end

        context "200 response" do
          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :user => "abc123"}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).exactly(4).times.and_return(200)
            expect(notification.send(user)).to eq(true)
          end
        end

        context "unexpected response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :user => "abc123"}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).exactly(4).times.and_return(500)
            expect {notification.send(user)}.to raise_error(RuntimeError, "Unexpected error sending notification")
          end
        end
      end

      context "#batch_send" do
        let(:mock_request) { double("request") }
        let(:mock_response) { double("response") }
        let(:notification) { Notification.new(group_key: "foo", setting_key: "bar", message: "hi mom") }
        let(:error_response) { {parameter: "foo", message: "something bad has happened"}.to_json }
        let(:user1) { User.new(identifier: "abc123") }
        let(:user2) { User.new(identifier: "def456") }
        let(:users) { [user1, user2] }

        context "403 response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :users => ["abc123", "def456"]}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).and_return(403)
            expect {notification.batch_send(users)}.to raise_error(RuntimeError, "Access denied. You must use your Master OAuth client_id and client_secret to send push notifications.")
          end
        end

        context "404 response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :users => ["abc123", "def456"]}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).twice.and_return(404)
            expect(mock_response).to receive(:body).and_return(error_response)
            expect {notification.batch_send(users)}.to raise_error(RuntimeError, "something bad has happened")
          end
        end

        context "422 response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :users => ["abc123", "def456"]}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).exactly(3).times.and_return(422)
            expect(mock_response).to receive(:body).and_return(error_response)
            expect {notification.batch_send(users)}.to raise_error(RuntimeError, "something bad has happened")
          end
        end

        context "200 response" do
          it "returns true" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :users => ["abc123", "def456"]}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).exactly(4).times.and_return(200)
            expect(notification.batch_send(users)).to eq(true)
          end
        end

        context "unexpected response" do
          it "raises an error" do
            expect(Togglehq::Request).to receive(:new).with("/notifications",
                                                            :notification => {:group => "foo",
                                                                              :setting => "bar",
                                                                              :message => "hi mom",
                                                                              :users => ["abc123", "def456"]}).and_return(mock_request)
            expect(mock_request).to receive(:post!).and_return(mock_response)
            expect(mock_response).to receive(:status).exactly(4).times.and_return(500)
            expect {notification.batch_send(users)}.to raise_error(RuntimeError, "Unexpected error sending batch notification")
          end
        end
      end
    end
  end
end

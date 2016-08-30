require 'spec_helper'

module Togglehq
  module Notify
    describe Notification do
      describe 'when creating a new notification' do
        before(:each) do
          Togglehq.configure do |config|
            config.client_id = "183b29ffbca42e6e1aca94e8fada7f5ade9e9276593a7bb91e6d6837ff212dc3"
            config.client_secret = "59d41a32533b9d06b1f94e5ff067427dcf9a518a75fbb6d3a564b33a2d459f6b"
          end
        end

        xit "allows you to create a notification" do
          notification = Togglehq::Notify::Notification.new(
            :notification_type => "first_setting",
            :users => [0,1,2],
            :message => "test!")

          response = notification.push!
          expect(response).to eq({"message"=>"Notification created successfully"})
        end
      end
    end
  end
end
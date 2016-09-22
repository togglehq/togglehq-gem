module Togglehq
  module Notify
    class Notification
      attr_accessor :category_key, :preference_key, :message

      def initialize(params = {})
        @category_key = params[:category_key]
        @preference_key = params[:preference_key]
        @message = params[:message]
      end

      # Sends this notification to the given user.
      # @param user [Togglehq::Notify::User] the user to send the notification to
      # @raise [RuntimeError] raised if an error occurs sending the notification
      def send(user)
        response = Togglehq::Request.new("/notifications",
                                         {:notification => {:category => self.category_key,
                                                            :preference => self.preference_key,
                                                            :message => self.message,
                                                            :user => user.identifier}}).post!
        if response.status == 403
          raise "Access denied. You must use your Master OAuth client_id and client_secret to send push notifications."
        elsif response.status == 404 || response.status == 422
          json = JSON.parse(response.body)
          raise json["message"]
        elsif response.status == 200
          return true
        else
          raise "Unexpected error sending notification"
        end
      end

      # Sends this notification to the given set of users. You may only send to up to 100 users at a time.
      # @param users [array of Togglehq::Notify::User] the users to send the notification to
      # @raise [RuntimeError] raised if an error occurs sending the notification
      def batch_send(users)
        response = Togglehq::Request.new("/notifications",
                                         {:notification => {:category => self.category_key,
                                                            :preference => self.preference_key,
                                                            :message => self.message,
                                                            :users => users.map {|u| u.identifier}}}).post!
        if response.status == 403
          raise "Access denied. You must use your Master OAuth client_id and client_secret to send push notifications."
        elsif response.status == 404 || response.status == 422
          json = JSON.parse(response.body)
          raise json["message"]
        elsif response.status == 200
          return true
        else
          raise "Unexpected error sending batch notification"
        end
      end

      # Sends this notification as a global notification to all of this app's users.
      # @raise [RuntimeError] raised if an error occurs sending the notification
      def send_global
        response = Togglehq::Request.new("/notifications",
                                         {:notification => {:category => self.category_key,
                                                            :preference => self.preference_key,
                                                            :message => self.message,
                                                            :global => true}}).post!
        if response.status == 403
          raise "Access denied. You must use your Master OAuth client_id and client_secret to send push notifications."
        elsif response.status == 404 || response.status == 422
          json = JSON.parse(response.body)
          raise json["message"]
        elsif response.status == 200
          return true
        else
          raise "Unexpected error sending global notification"
        end
      end
    end
  end
end

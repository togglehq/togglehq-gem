module Togglehq
  class NotificationBatch
    attr_accessor :external_id, :batch_number, :message, :certificate, :tokens, :sandbox

    def initialize(params = {})
      @external_id = params[:external_id]
      @batch_number = params[:batch_number]
      @message = params[:message]
      @certificate = params[:certificate]
      @tokens = params[:token] ? [params[:token]] : params[:tokens]
      @sandbox = params[:sandbox] || true
    end

    def push!
      Togglehq::Request.new("notification_batches", {
        external_id: external_id,
        batch_number: batch_number,
        message: message,
        certificate: certificate,
        tokens: tokens,
        sandbox: sandbox
      }).post!
    end
  end
end

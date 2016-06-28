require 'togglehq/version'
require 'togglehq/config'
require 'togglehq/request'
require 'togglehq/notification'
require 'togglehq/notification_batch'

module Togglehq
  class << self
    attr_writer :config
  end

  def self.config
    @config ||= Config.new
  end

  def self.reset
    @config = Config.new
  end

  def self.configure
    yield config
  end
end

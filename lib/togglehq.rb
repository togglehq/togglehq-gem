require 'togglehq/version'
require 'togglehq/config'
require 'togglehq/request'
require 'togglehq/user'
require 'logger'

require 'togglehq/notify'

module Togglehq
  class << self
    attr_writer :config, :cache
  end

  def self.config
    @config ||= Config.new
  end

  def self.cache
    @cache ||= Hash.new
  end

  def self.reset
    @config = Config.new
  end

  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end

  def self.configure
    yield config
  end

  def self.connection
    conn = Faraday.new(:url => config.uri) do |faraday|
      faraday.adapter config.adapter
      faraday.response :logger, self.logger, bodies: true if config.log_requests
    end
    conn
  end
end

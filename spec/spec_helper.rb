$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start do
  add_filter "spec"
end
require 'togglehq'
#require 'webmock/minitest'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures"
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

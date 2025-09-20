# frozen_string_literal: true

# WebMock configuration for HTTP request stubbing
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

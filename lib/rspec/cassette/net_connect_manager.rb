# frozen_string_literal: true

require "webmock"

module RSpec
  module Cassette
    class NetConnectManager
      def initialize(configuration)
        @configuration = configuration
      end

      def disable!
        return if @configuration.allow_http_connections_when_no_cassette

        WebMock.disable_net_connect!
      end

      def restore!
        return if @configuration.allow_http_connections_when_no_cassette

        WebMock.allow_net_connect!
      end
    end
  end
end

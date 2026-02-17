# frozen_string_literal: true

require "webmock"

module RSpec
  module Cassette
    class NetConnectManager
      IgnoredRequest = Struct.new(:uri)

      def initialize(configuration)
        @configuration = configuration
      end

      def disable!
        return if @configuration.allow_http_connections_when_no_cassette

        options = {}
        options[:allow_localhost] = true if @configuration.ignore_localhost

        allow_list = build_allow_list
        options[:allow] = allow_list unless allow_list.empty?

        WebMock.disable_net_connect!(**options)
      end

      def restore!
        return if @configuration.allow_http_connections_when_no_cassette

        WebMock.allow_net_connect!
      end

      private

      def build_allow_list
        allow_list = @configuration.ignore_hosts.dup
        allow_list.concat(ignore_request_matchers)
        allow_list
      end

      def ignore_request_matchers
        @configuration.ignore_request_blocks.map do |block|
          lambda do |uri|
            block.call(IgnoredRequest.new(uri.to_s))
          end
        end
      end
    end
  end
end

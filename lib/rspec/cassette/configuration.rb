# frozen_string_literal: true

module RSpec
  module Cassette
    class Configuration
      attr_accessor :cassettes_dir,
                    :default_match_on,
                    :allow_http_connections_when_no_cassette,
                    :ignore_localhost,
                    :ignore_hosts
      attr_reader :ignore_request_blocks

      def initialize
        @cassettes_dir = "spec/fixtures/cassettes"
        @default_match_on = %i[method uri]
        @allow_http_connections_when_no_cassette = false
        @ignore_localhost = false
        @ignore_hosts = []
        @ignore_request_blocks = []
      end

      def ignore_request(&block)
        @ignore_request_blocks << block if block
      end
    end
  end
end

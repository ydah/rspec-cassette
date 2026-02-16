# frozen_string_literal: true

module RSpec
  module Cassette
    class Configuration
      attr_accessor :cassettes_dir, :default_match_on

      def initialize
        @cassettes_dir = "spec/fixtures/cassettes"
        @default_match_on = %i[method uri]
      end
    end
  end
end

# frozen_string_literal: true

require "webmock"

module RSpec
  module Cassette
    class StubRegistrar
      def initialize(cassette, match_on: nil)
        @cassette = cassette
        @match_on = Array(match_on || RSpec::Cassette.configuration.default_match_on)
      end

      def register!
        grouped_interactions.each do |(method, uri), interactions|
          stub = WebMock.stub_request(method, uri)
          stub = apply_matchers(stub, interactions.first)
          stub.to_return(*interactions.map { |interaction| build_response(interaction) })
        end
      end

      private

      def grouped_interactions
        @cassette.interactions.group_by { |interaction| [interaction.method, interaction.uri] }
      end

      def apply_matchers(stub, interaction)
        matcher_options = {}
        matcher_options[:body] = interaction.request_body if @match_on.include?(:body)
        matcher_options[:headers] = interaction.request_headers if @match_on.include?(:headers)
        return stub if matcher_options.empty?

        stub.with(matcher_options)
      end

      def build_response(interaction)
        {
          status: interaction.status,
          body: interaction.response_body,
          headers: interaction.response_headers
        }
      end
    end
  end
end

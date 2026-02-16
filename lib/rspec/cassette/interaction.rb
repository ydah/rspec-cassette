# frozen_string_literal: true

module RSpec
  module Cassette
    class Interaction
      attr_reader :request, :response

      def initialize(raw_interaction)
        @request = raw_interaction.fetch("request")
        @response = raw_interaction.fetch("response")
      end

      def method
        request.fetch("method").to_sym
      end

      def uri
        request.fetch("uri")
      end

      def request_headers
        request.fetch("headers", {}) || {}
      end

      def request_body
        body = request.fetch("body", {}) || {}
        body.fetch("string", "")
      end

      def status
        response.fetch("status", {}).fetch("code")
      end

      def response_headers
        response.fetch("headers", {}) || {}
      end

      def response_body
        body = response.fetch("body", {}) || {}
        body.fetch("string", "")
      end
    end
  end
end

# frozen_string_literal: true

require_relative "cassette/version"
require_relative "cassette/errors"
require_relative "cassette/configuration"
require_relative "cassette/cassette"
require_relative "cassette/interaction"
require_relative "cassette/stub_registrar"

module RSpec
  module Cassette
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end
    end
  end
end

# frozen_string_literal: true

module RSpec
  module Cassette
    class Error < StandardError; end
    class CassetteNotFoundError < Error; end
    class CassetteParseError < Error; end
  end
end

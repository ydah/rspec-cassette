# frozen_string_literal: true

require "yaml"
require "time"

module RSpec
  module Cassette
    class Cassette
      attr_reader :interactions, :path

      def initialize(path)
        @path = resolve_path(path)
        @interactions = load_interactions(@path)
      end

      private

      def resolve_path(path)
        expanded = path.end_with?(".yml") ? path : "#{path}.yml"
        return expanded if File.exist?(expanded)

        raise CassetteNotFoundError, "Cassette not found: #{expanded}"
      end

      def load_interactions(path)
        data = YAML.safe_load(
          File.read(path),
          permitted_classes: [Time, Symbol],
          aliases: true
        )

        raw_interactions = Array(data.fetch("http_interactions"))
        raw_interactions.map { |raw| Interaction.new(raw) }
      rescue KeyError, Psych::Exception => e
        raise CassetteParseError, "Cassette parse error: #{e.message}"
      end
    end
  end
end

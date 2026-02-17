# frozen_string_literal: true

module RSpec
  module Cassette
    class MetadataResolver
      def initialize(example)
        @example = example
      end

      def resolve
        return resolved_from_use_cassette if metadata.key?(:use_cassette)

        resolved_from_vcr_metadata
      end

      private

      attr_reader :example

      def metadata
        example.metadata
      end

      def resolved_from_use_cassette
        return nil unless metadata.key?(:use_cassette)

        cassette_name = metadata[:use_cassette]
        return nil unless cassette_name

        {
          cassette_name: cassette_name,
          cassette_options: normalize_cassette_options(metadata[:cassette_options])
        }
      end

      def resolved_from_vcr_metadata
        vcr_metadata = metadata[:vcr]
        return nil if vcr_metadata.nil? || vcr_metadata == false

        return resolved_from_vcr_hash(vcr_metadata) if vcr_metadata.is_a?(Hash)

        {
          cassette_name: build_vcr_compatible_cassette_name,
          cassette_options: {}
        }
      end

      def resolved_from_vcr_hash(vcr_metadata)
        cassette_name = fetch_vcr_cassette_name(vcr_metadata)
        cassette_options = normalize_vcr_options(vcr_metadata)

        {
          cassette_name: cassette_name || build_vcr_compatible_cassette_name,
          cassette_options: cassette_options
        }
      end

      def normalize_vcr_options(vcr_metadata)
        options = copy_hash_without_keys(vcr_metadata, :cassette_name, "cassette_name")
        normalized_options = symbolize_hash_keys(options)

        if normalized_options.key?(:match_requests_on)
          normalized_options[:match_on] = normalized_options[:match_requests_on] unless normalized_options.key?(:match_on)
          normalized_options.delete(:match_requests_on)
        end

        normalized_options
      end

      def fetch_vcr_cassette_name(vcr_metadata)
        return vcr_metadata[:cassette_name] if vcr_metadata.key?(:cassette_name)
        return vcr_metadata["cassette_name"] if vcr_metadata.key?("cassette_name")

        nil
      end

      def normalize_cassette_options(options)
        return {} unless options.is_a?(Hash)

        symbolize_hash_keys(options)
      end

      def symbolize_hash_keys(hash)
        hash.each_with_object({}) do |(key, value), normalized|
          normalized[key.is_a?(String) ? key.to_sym : key] = value
        end
      end

      def copy_hash_without_keys(hash, *keys)
        hash.each_with_object({}) do |(key, value), copied|
          copied[key] = value unless keys.include?(key)
        end
      end

      def build_vcr_compatible_cassette_name
        parts = example.example_group.parent_groups.reverse.map(&:description)
        parts << example.description

        parts
          .compact
          .map(&:to_s)
          .map(&:strip)
          .reject(&:empty?)
          .map { |part| normalize_cassette_name_part(part) }
          .join("/")
      end

      def normalize_cassette_name_part(part)
        part.split("/").map { |segment| segment.gsub(/[^\w]+/, "_") }.join("/")
      end
    end
  end
end

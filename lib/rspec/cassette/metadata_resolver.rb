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
        sanitize_cassette_name(self.class.build_name_from_metadata(metadata))
      end

      def sanitize_cassette_name(name)
        name.gsub(/[^[:word:]\-\/]+/, "_")
      end

      def self.build_name_from_metadata(source_metadata)
        description =
          if source_metadata[:description].to_s.empty?
            source_metadata[:scoped_id].to_s
          else
            source_metadata[:description].to_s
          end
        example_group = if source_metadata.key?(:example_group)
                          source_metadata[:example_group]
                        else
                          source_metadata[:parent_example_group]
                        end

        if example_group
          [build_name_from_metadata(example_group), description].join("/")
        else
          description
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rspec/cassette"

module RSpec
  module Cassette
    module RSpecHelper
      def use_cassette(name, **options)
        cassette = Cassette.new(cassette_path(name))
        StubRegistrar.new(cassette, match_on: options[:match_on]).register!
      end

      private

      def cassette_path(name)
        base_dir = RSpec::Cassette.configuration.cassettes_dir
        File.join(base_dir, name)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Cassette::RSpecHelper

  config.around(:each) do |example|
    cassette_name = example.metadata[:use_cassette] || example.metadata[:rspec_replay]
    options = example.metadata[:cassette_options] || example.metadata[:rspec_replay_options]
    use_cassette(cassette_name, **options) if cassette_name
    example.run
  end
end

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
    manager = RSpec::Cassette::NetConnectManager.new(RSpec::Cassette.configuration)
    manager.disable!

    begin
      resolved = RSpec::Cassette::MetadataResolver.new(example).resolve
      use_cassette(resolved[:cassette_name], **resolved[:cassette_options]) if resolved
      example.run
    ensure
      manager.restore!
    end
  end
end

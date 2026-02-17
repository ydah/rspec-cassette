# frozen_string_literal: true

RSpec.describe RSpec::Cassette::Configuration do
  subject(:configuration) { described_class.new }

  it "provides defaults" do
    expect(configuration.cassettes_dir).to eq("spec/fixtures/cassettes")
    expect(configuration.default_match_on).to eq(%i[method uri])
    expect(configuration.allow_http_connections_when_no_cassette).to be(false)
  end

  it "allows overriding allow_http_connections_when_no_cassette" do
    configuration.allow_http_connections_when_no_cassette = true

    expect(configuration.allow_http_connections_when_no_cassette).to be(true)
  end
end

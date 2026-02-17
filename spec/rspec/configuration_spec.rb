# frozen_string_literal: true

RSpec.describe RSpec::Cassette::Configuration do
  subject(:configuration) { described_class.new }

  it "provides defaults" do
    expect(configuration.cassettes_dir).to eq("spec/fixtures/cassettes")
    expect(configuration.default_match_on).to eq(%i[method uri])
    expect(configuration.allow_http_connections_when_no_cassette).to be(false)
    expect(configuration.ignore_localhost).to be(false)
    expect(configuration.ignore_hosts).to eq([])
    expect(configuration.ignore_request_blocks).to eq([])
  end

  it "allows overriding allow_http_connections_when_no_cassette" do
    configuration.allow_http_connections_when_no_cassette = true

    expect(configuration.allow_http_connections_when_no_cassette).to be(true)
  end

  it "allows overriding ignore_localhost" do
    configuration.ignore_localhost = true

    expect(configuration.ignore_localhost).to be(true)
  end

  it "allows overriding ignore_hosts" do
    configuration.ignore_hosts = %w[selenium-hub chromedriver]

    expect(configuration.ignore_hosts).to eq(%w[selenium-hub chromedriver])
  end

  it "registers ignore_request blocks" do
    handler = lambda { |request| request.uri.include?("localhost") }

    configuration.ignore_request(&handler)

    expect(configuration.ignore_request_blocks).to eq([handler])
  end
end

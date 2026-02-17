# frozen_string_literal: true

RSpec.describe RSpec::Cassette::Cassette do
  let(:path) { "spec/fixtures/cassettes/users/index" }

  it "loads interactions" do
    cassette = described_class.new(path)

    expect(cassette.interactions.count).to eq(1)
    expect(cassette.interactions.first.uri).to eq("https://api.example.com/v1/users")
  end

  it "raises when missing" do
    expect { described_class.new("spec/fixtures/cassettes/missing") }
      .to raise_error(RSpec::Cassette::CassetteNotFoundError)
  end
end

RSpec.describe RSpec::Cassette do
  describe ".configuration" do
    it "provides defaults" do
      config = described_class.configuration

      expect(config.cassettes_dir).to eq("spec/fixtures/cassettes")
      expect(config.default_match_on).to eq(%i[method uri])
      expect(config.allow_http_connections_when_no_cassette).to be(false)
      expect(config.ignore_localhost).to be(false)
      expect(config.ignore_hosts).to eq([])
      expect(config.ignore_request_blocks).to eq([])
    end
  end
end

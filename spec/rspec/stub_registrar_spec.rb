# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe RSpec::Cassette::StubRegistrar do
  it "registers a stub with responses" do
    cassette = RSpec::Cassette::Cassette.new("spec/fixtures/cassettes/users/index")

    described_class.new(cassette).register!

    response = Net::HTTP.get(URI("https://api.example.com/v1/users"))
    expect(response).to eq("{\"users\":[{\"id\":1}]}")
  end
end

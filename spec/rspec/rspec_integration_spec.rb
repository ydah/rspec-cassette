# frozen_string_literal: true

require "webmock/rspec"
require "rspec/cassette/rspec"

RSpec.describe "RSpec::Cassette RSpec integration" do
  it "registers using helper" do
    use_cassette("users/index")

    response = Net::HTTP.get(URI("https://api.example.com/v1/users"))
    expect(response).to eq("{\"users\":[{\"id\":1}]}")
  end

  it "registers using metadata", use_cassette: "users/index" do
    response = Net::HTTP.get(URI("https://api.example.com/v1/users"))
    expect(response).to eq("{\"users\":[{\"id\":1}]}")
  end
end

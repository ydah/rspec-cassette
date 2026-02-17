# frozen_string_literal: true

require "webmock/rspec"
require "rspec/cassette/rspec_helper"

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

  it "registers using vcr metadata", vcr: { cassette_name: "users/index" } do
    response = Net::HTTP.get(URI("https://api.example.com/v1/users"))
    expect(response).to eq("{\"users\":[{\"id\":1}]}")
  end

  it "prioritizes use_cassette over vcr metadata",
     use_cassette: "users/index",
     vcr: { cassette_name: "missing/cassette" } do
    response = Net::HTTP.get(URI("https://api.example.com/v1/users"))
    expect(response).to eq("{\"users\":[{\"id\":1}]}")
  end
end

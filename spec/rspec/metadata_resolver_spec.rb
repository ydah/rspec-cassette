# frozen_string_literal: true

RSpec.describe RSpec::Cassette::MetadataResolver do
  subject(:resolved) { described_class.new(example_instance).resolve }
  let(:metadata) { {} }
  let(:example_description) { "example description" }
  let(:parent_group_descriptions) { [] }

  let(:example_group) do
    double(
      "ExampleGroup",
      parent_groups: parent_group_descriptions.map { |description| double("Group", description: description) }
    )
  end

  let(:example_instance) do
    double(
      "Example",
      metadata: metadata,
      description: example_description,
      example_group: example_group
    )
  end

  context "when use_cassette metadata is present" do
    let(:metadata) do
      {
        use_cassette: "users/index",
        cassette_options: { "match_on" => %i[method uri body] },
        vcr: { cassette_name: "ignored/by/priority" }
      }
    end

    it "prioritizes use_cassette over vcr metadata" do
      expect(resolved).to eq(
        cassette_name: "users/index",
        cassette_options: { match_on: %i[method uri body] }
      )
    end
  end

  context "when use_cassette is explicitly disabled" do
    let(:metadata) do
      {
        use_cassette: false,
        vcr: true
      }
    end

    it "does not resolve cassette even if vcr is present" do
      expect(resolved).to be_nil
    end
  end

  context "when vcr metadata is false" do
    let(:metadata) { { vcr: false } }

    it "does not resolve cassette" do
      expect(resolved).to be_nil
    end
  end

  context "when vcr metadata is true" do
    let(:metadata) { { vcr: true } }
    let(:parent_group_descriptions) { ["Request spec", "w/ valid params", nil, " "] }
    let(:example_description) { "#call 1.2.3.1" }

    it "builds vcr-compatible cassette name from descriptions" do
      expect(resolved).to eq(
        cassette_name: "w/_valid_params/Request_spec/_call_1_2_3_1",
        cassette_options: {}
      )
    end
  end

  context "when vcr metadata is a hash with cassette_name and match_requests_on" do
    let(:metadata) do
      {
        vcr: {
          "cassette_name" => "users/index",
          "match_requests_on" => %i[method uri body]
        }
      }
    end

    it "converts match_requests_on to match_on" do
      expect(resolved).to eq(
        cassette_name: "users/index",
        cassette_options: { match_on: %i[method uri body] }
      )
    end
  end

  context "when vcr metadata has both match_on and match_requests_on" do
    let(:metadata) do
      {
        vcr: {
          cassette_name: "users/index",
          match_on: %i[method uri],
          match_requests_on: %i[method uri body]
        }
      }
    end

    it "keeps explicit match_on and drops match_requests_on" do
      expect(resolved).to eq(
        cassette_name: "users/index",
        cassette_options: { match_on: %i[method uri] }
      )
    end
  end

  context "when vcr metadata is truthy but not a hash" do
    let(:metadata) { { vcr: "enabled" } }
    let(:parent_group_descriptions) { ["API/v1"] }
    let(:example_description) { "GET #show" }

    it "treats it as enabled and resolves cassette name automatically" do
      expect(resolved).to eq(
        cassette_name: "API/v1/GET_show",
        cassette_options: {}
      )
    end
  end

end

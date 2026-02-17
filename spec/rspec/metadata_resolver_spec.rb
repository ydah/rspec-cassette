# frozen_string_literal: true

RSpec.describe RSpec::Cassette::MetadataResolver do
  subject(:resolved) { described_class.new(example_instance).resolve }
  let(:metadata) { {} }

  let(:example_instance) do
    double(
      "Example",
      metadata: metadata
    )
  end

  context "when use_cassette metadata is present" do
    let(:metadata) do
      {
        use_cassette: "resource/path",
        cassette_options: { "match_on" => %i[method uri body] },
        vcr: { cassette_name: "ignored/path/by_priority" }
      }
    end

    it "prioritizes use_cassette over vcr metadata" do
      expect(resolved).to eq(
        cassette_name: "resource/path",
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
    let(:metadata) do
      {
        vcr: true,
        description: "#action 1.2.3.1",
        example_group: {
          description: "w/ sample params",
          example_group: {
            description: "Top level spec"
          }
        }
      }
    end

    it "builds vcr-compatible cassette name from descriptions" do
      expect(resolved).to eq(
        cassette_name: "Top_level_spec/w/_sample_params/_action_1_2_3_1",
        cassette_options: {}
      )
    end
  end

  context "when vcr metadata is a hash with cassette_name and match_requests_on" do
    let(:metadata) do
      {
        vcr: {
          "cassette_name" => "resource/path",
          "match_requests_on" => %i[method uri body]
        }
      }
    end

    it "converts match_requests_on to match_on" do
      expect(resolved).to eq(
        cassette_name: "resource/path",
        cassette_options: { match_on: %i[method uri body] }
      )
    end
  end

  context "when vcr metadata has both match_on and match_requests_on" do
    let(:metadata) do
      {
        vcr: {
          cassette_name: "resource/path",
          match_on: %i[method uri],
          match_requests_on: %i[method uri body]
        }
      }
    end

    it "keeps explicit match_on and drops match_requests_on" do
      expect(resolved).to eq(
        cassette_name: "resource/path",
        cassette_options: { match_on: %i[method uri] }
      )
    end
  end

  context "when vcr metadata is truthy but not a hash" do
    let(:metadata) do
      {
        vcr: "enabled",
        description: "FETCH #item",
        example_group: { description: "Public/v1" }
      }
    end

    it "treats it as enabled and resolves cassette name automatically" do
      expect(resolved).to eq(
        cassette_name: "Public/v1/FETCH_item",
        cassette_options: {}
      )
    end
  end

  context "when vcr metadata includes non-ascii descriptions" do
    let(:metadata) do
      {
        vcr: true,
        description: "多言語 テストケース",
        example_group: { description: "General Context" }
      }
    end

    it "keeps non-ascii characters while normalizing spaces" do
      expect(resolved).to eq(
        cassette_name: "General_Context/多言語_テストケース",
        cassette_options: {}
      )
    end
  end

  context "when example description is empty" do
    let(:metadata) do
      {
        vcr: true,
        description: "",
        scoped_id: "1:2",
        example_group: { description: "Top level spec" }
      }
    end

    it "uses scoped_id for the cassette name" do
      expect(resolved).to eq(
        cassette_name: "Top_level_spec/1_2",
        cassette_options: {}
      )
    end
  end
end

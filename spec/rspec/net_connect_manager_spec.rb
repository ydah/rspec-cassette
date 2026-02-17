# frozen_string_literal: true

require "uri"

RSpec.describe RSpec::Cassette::NetConnectManager do
  let(:configuration) { RSpec::Cassette::Configuration.new }
  subject(:manager) { described_class.new(configuration) }

  describe "#disable!" do
    context "when allow_http_connections_when_no_cassette is false" do
      it "disables net connections" do
        allow(WebMock).to receive(:disable_net_connect!)

        manager.disable!

        expect(WebMock).to have_received(:disable_net_connect!).with(no_args)
      end
    end

    context "when allow_http_connections_when_no_cassette is true" do
      it "does not disable net connections" do
        configuration.allow_http_connections_when_no_cassette = true
        allow(WebMock).to receive(:disable_net_connect!)

        manager.disable!

        expect(WebMock).not_to have_received(:disable_net_connect!)
      end
    end

    context "when ignore_localhost is true" do
      it "passes allow_localhost option" do
        configuration.ignore_localhost = true
        allow(WebMock).to receive(:disable_net_connect!)

        manager.disable!

        expect(WebMock).to have_received(:disable_net_connect!).with(allow_localhost: true)
      end
    end

    context "when ignore_hosts are configured" do
      it "passes allow option with the configured hosts" do
        configuration.ignore_hosts = %w[selenium-hub chromedriver]
        allow(WebMock).to receive(:disable_net_connect!)

        manager.disable!

        expect(WebMock).to have_received(:disable_net_connect!)
          .with(allow: %w[selenium-hub chromedriver])
      end
    end

    context "when ignore_localhost and ignore_hosts are configured" do
      it "passes both allow_localhost and allow options" do
        configuration.ignore_localhost = true
        configuration.ignore_hosts = ["selenium-hub"]
        allow(WebMock).to receive(:disable_net_connect!)

        manager.disable!

        expect(WebMock).to have_received(:disable_net_connect!)
          .with(allow_localhost: true, allow: ["selenium-hub"])
      end
    end

    context "when ignore_request block is configured" do
      it "converts block to a WebMock allow matcher" do
        configuration.ignore_request do |request|
          URI(request.uri).port == 9200
        end

        expect(WebMock).to receive(:disable_net_connect!) do |**options|
          expect(options[:allow]).to be_an(Array)
          expect(options[:allow].size).to eq(1)

          matcher = options[:allow].first
          expect(matcher.call(URI("http://example.test:9200"))).to be(true)
          expect(matcher.call(URI("http://example.test:443"))).to be(false)
        end

        manager.disable!
      end
    end

    context "when ignore_hosts and ignore_request are configured together" do
      it "keeps both host and block matchers in allow list" do
        configuration.ignore_hosts = ["selenium-hub"]
        configuration.ignore_request { |request| request.uri.include?("localhost") }

        expect(WebMock).to receive(:disable_net_connect!) do |**options|
          expect(options[:allow].first).to eq("selenium-hub")
          expect(options[:allow].last.call(URI("http://localhost:3000"))).to be(true)
        end

        manager.disable!
      end
    end
  end

  describe "#restore!" do
    context "when allow_http_connections_when_no_cassette is false" do
      it "restores net connections" do
        allow(WebMock).to receive(:allow_net_connect!)

        manager.restore!

        expect(WebMock).to have_received(:allow_net_connect!).with(no_args)
      end
    end

    context "when allow_http_connections_when_no_cassette is true" do
      it "does not change net connection settings" do
        configuration.allow_http_connections_when_no_cassette = true
        allow(WebMock).to receive(:allow_net_connect!)

        manager.restore!

        expect(WebMock).not_to have_received(:allow_net_connect!)
      end
    end
  end
end

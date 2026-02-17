# frozen_string_literal: true

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

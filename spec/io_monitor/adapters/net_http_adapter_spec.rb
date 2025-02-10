# frozen_string_literal: true

RSpec.describe IoMonitor::NetHttpAdapter do
  let(:aggregator) { IoMonitor.aggregator }
  let(:body) { "Hello, World!" }
  let(:url) { "www.example.com" }

  before do
    stub_request(:get, url).to_return body: body
  end

  around do |example|
    aggregator.collect { example.run }
  end

  context "when aggregator is inactive" do
    before do
      aggregator.stop!
    end

    it "does nothing" do
      expect(aggregator).not_to receive(:increment)

      Net::HTTP.get url, "/"
    end
  end

  it "increments aggregator by request's body bytesize" do
    allow(aggregator).to receive(:increment)

    Net::HTTP.get url, "/"

    expect(aggregator).to have_received(:increment).with(described_class.kind, body.bytesize)
  end

  it "does not fail when read_body was called with a block" do
    allow(aggregator).to receive(:increment)

    parsed_uri = URI("http://#{url}")

    Net::HTTP.start(url, 80) do |http|
      request = Net::HTTP::Get.new parsed_uri

      http.request request do |response|
        response.read_body { |_chunk| }
        expect(response.body).to be_an_instance_of ::Net::ReadAdapter
      end
    end

    expect(aggregator).to have_received(:increment).with(described_class.kind, body.bytesize)
  end
end

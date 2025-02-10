# frozen_string_literal: true

module IoMonitor
  module NetHttpAdapterPatch
    def request(*args, &block)
      super.tap do |response|
        if IoMonitor.aggregator.active? && response&.body.respond_to?(:bytesize)
          IoMonitor.aggregator.increment(NetHttpAdapter.kind, response.body.bytesize)
        end
      end
    end
  end
end

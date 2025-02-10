# frozen_string_literal: true

module IoMonitor
  module NetReadAdapterPatch
    def <<(str)
      if IoMonitor.aggregator.active?
        IoMonitor.aggregator.increment(NetHttpAdapter.kind, str.bytesize)
      end
      super
    end
  end
end

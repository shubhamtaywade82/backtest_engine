module BacktestEngine
  module Market
    class ContextBuilder
      def self.build(index_candle:, indicators:, ltp:)
        {
          time: index_candle.timestamp,
          price: index_candle.close,
          structure: indicators[:structure],
          pullback: indicators[:pullback],
          volume_spike: indicators[:volume_spike],
          ltp: ltp
        }
      end
    end
  end
end


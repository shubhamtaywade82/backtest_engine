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
          iv: indicators[:iv],
          iv_percentile: indicators[:iv_percentile],
          htf_bias: indicators[:htf_bias],
          regime_score: indicators[:regime_score],
          regime_stable: indicators[:regime_stable],
          ltp: ltp
        }
      end
    end
  end
end


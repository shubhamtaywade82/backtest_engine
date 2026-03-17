module BacktestEngine
  module Data
    class DatasetBuilder
      def initialize(interval:, from:, to:, expiry_code:, security_id: IndexLoader::NIFTY_SECURITY_ID, strikes: OptionsLoader::DEFAULT_STRIKES)
        @interval = interval
        @from = from
        @to = to
        @expiry_code = expiry_code
        @security_id = security_id
        @strikes = strikes
      end

      def build
        index = IndexLoader.fetch(
          interval: interval,
          from: from,
          to: to,
          security_id: security_id
        )

        options = OptionsLoader.fetch(
          interval: interval,
          from: from,
          to: to,
          expiry_code: expiry_code,
          security_id: security_id,
          strikes: strikes
        )

        align(index, options)
      end

      private

      attr_reader :interval, :from, :to, :expiry_code, :security_id, :strikes

      def align(index_candles, options)
        index_candles.map do |candle|
          {
            timestamp: candle.timestamp,
            index: candle,
            options: options_at(candle.timestamp, options)
          }
        end
      end

      def options_at(timestamp, options)
        options.each_with_object({}) do |((strike, type), candles), result|
          match = candles.find { |candle| candle[:timestamp] == timestamp || candle[:timestamp] == timestamp.to_i }
          result[[strike, type]] = match if match
        end
      end
    end
  end
end


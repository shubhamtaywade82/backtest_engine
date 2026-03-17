module BacktestEngine
  module Data
    class InstrumentMetadata
      LOT_SIZES = {
        "NIFTY" => 50,
        "BANKNIFTY" => 15,
        "SENSEX" => 10
      }.freeze

      def self.lot_size(symbol)
        LOT_SIZES.fetch(symbol) do
          raise ArgumentError, "Unknown symbol: #{symbol}"
        end
      end
    end
  end
end


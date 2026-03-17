module BacktestEngine
  class OptionMapper
    STRIKE_STEP = 50

    # option_data structure:
    # {
    #   call: { 23500 => [ { timestamp:, open:, high:, low:, close:, iv:, oi:, spot: }, ... ], ... },
    #   put:  { 23500 => [ { timestamp:, ... }, ... ], ... }
    # }
    def initialize(option_data)
      @option_data = option_data
    end

    def atm_strike(spot)
      return nil unless spot

      (spot.to_f / STRIKE_STEP).round * STRIKE_STEP
    end

    def select_strike(spot, bias)
      base_strike = atm_strike(spot)
      return nil unless base_strike

      case bias
      when :bullish
        { type: :call, strike: base_strike }
      when :bearish
        { type: :put, strike: base_strike }
      else
        nil
      end
    end

    def price_at(timestamp, strike, type)
      candles = candles_for(strike, type)
      return nil unless candles

      candles.find { |candle| candle[:timestamp] == timestamp }
    end

    private

    def candles_for(strike, type)
      typed = @option_data[type]
      return nil unless typed

      typed[strike]
    end
  end
end


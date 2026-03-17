require "date"

module BacktestEngine
  module Data
    class OptionsLoader
      DEFAULT_SECURITY_ID = 13
      DEFAULT_STRIKES = %w[ATM ATM+1 ATM-1 ATM+2 ATM-2].freeze

      def self.fetch(interval:, from:, to:, expiry: "WEEK", expiry_code:, security_id: DEFAULT_SECURITY_ID, strikes: DEFAULT_STRIKES)
        require "dhan_hq"

        raise ArgumentError, "expiry_code is required for expired options backfill" if expiry_code.nil?

        from_date = normalize_date(from)
        to_date = normalize_date(to)

        strikes.each_with_object({}) do |strike, result|
          %w[CALL PUT].each do |type|
            data = DhanHQ::Models::ExpiredOptionsData.fetch(
              security_id: security_id,
              exchange_segment: "NSE_FNO",
              instrument: "OPTIDX",
              expiry_flag: expiry,
              expiry_code: expiry_code,
              strike: strike,
              drv_option_type: type,
              interval: interval.to_s,
              from_date: from_date,
              to_date: to_date,
              required_data: %w[open high low close volume oi iv strike spot]
            )

            candles = data.to_candles(type)
            key = [strike, type.downcase.to_sym]
            result[key] = candles
          end
        end
      end

      def self.normalize_date(value)
        Date.parse(value.to_s).strftime("%Y-%m-%d")
      end

      private_class_method :normalize_date
    end
  end
end


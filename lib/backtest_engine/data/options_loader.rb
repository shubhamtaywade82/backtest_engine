require "date"

module BacktestEngine
  module Data
    class OptionsLoader
      DEFAULT_SECURITY_ID = 13
      DEFAULT_STRIKES = %w[ATM ATM+1 ATM-1 ATM+2 ATM-2].freeze

      def self.fetch(interval:, from:, to:, expiry: "WEEK", expiry_code:, security_id: DEFAULT_SECURITY_ID, strikes: DEFAULT_STRIKES)
        require "dhan_hq"

        validate_expiry_code!(expiry_code)

        from_date, to_date = normalize_date_range(from, to)

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

      def self.normalize_date_range(from, to)
        from_date = Date.parse(from.to_s)
        to_date = Date.parse(to.to_s)

        # DhanHQ ExpiredOptionsData validates `from_date` must be strictly before `to_date`.
        to_date = from_date + 1 if from_date >= to_date

        [from_date.strftime("%Y-%m-%d"), to_date.strftime("%Y-%m-%d")]
      end

      def self.validate_expiry_code!(expiry_code)
        value = Integer(expiry_code, exception: false)
        return if value && value.positive?

        raise ArgumentError, "expiry_code must be a positive Integer for ExpiredOptionsData.fetch (example: 1). Got: #{expiry_code.inspect}"
      end

      private_class_method :normalize_date_range
      private_class_method :validate_expiry_code!
    end
  end
end


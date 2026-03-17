module BacktestEngine
  module Strategies
    class ExpiryTrendV1
      ENTRY_WINDOW = ("11:30".."14:00").freeze
      MAX_HOLD_MINUTES = 25
      SL_PCT = 30
      TARGET_PCT = 60
      TRAIL_TRIGGER = 40

      def initialize(context:)
        @context = context
      end

      def call
        return no_trade!("Outside time window") unless valid_time?
        return no_trade!("No structure") unless tradable_structure?

        if bullish_setup?
          build_trade(:call)
        elsif bearish_setup?
          build_trade(:put)
        else
          no_trade!("No setup")
        end
      end

      private

      attr_reader :context

      def valid_time?
        time = context[:time]
        return false unless time.respond_to?(:strftime)

        ENTRY_WINDOW.cover?(time.strftime("%H:%M"))
      end

      def tradable_structure?
        return false unless %i[bullish bearish].include?(context[:structure])

        iv = context[:iv]
        return true if iv.nil?

        iv < 60 # simple guard: skip ultra-high IV regimes
      end

      def bullish_setup?
        context[:structure] == :bullish &&
          context[:pullback] &&
          context[:volume_spike]
      end

      def bearish_setup?
        context[:structure] == :bearish &&
          context[:pullback] &&
          context[:volume_spike]
      end

      def build_trade(option_type)
        {
          action: :buy,
          option_type: option_type,
          strike: :atm,
          sl_pct: SL_PCT,
          target_pct: TARGET_PCT,
          trail: true,
          trail_trigger: TRAIL_TRIGGER,
          max_hold_minutes: MAX_HOLD_MINUTES
        }
      end

      def no_trade!(reason)
        {
          action: :skip,
          reason: reason
        }
      end
    end
  end
end


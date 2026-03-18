# frozen_string_literal: true

module BacktestEngine
  module Strategies
    class Router
      # Normal day: S2 (trend/pullback), S4 (breakout). Expiry day: E4 only. Chop: no trade.
      TRADABLE_SESSIONS_NORMAL = %i[s2 s4].freeze
      TRADABLE_SESSIONS_EXPIRY = %i[e4].freeze
      TRADABLE_REGIMES = %i[trend_bull trend_bear].freeze

      def tradable?(session:, day_type:, regime:)
        return false if session.nil? || regime.nil?
        return false unless TRADABLE_REGIMES.include?(regime.to_sym)
        return false if regime.to_sym == :chop

        sessions = day_type.to_sym == :expiry ? TRADABLE_SESSIONS_EXPIRY : TRADABLE_SESSIONS_NORMAL
        sessions.include?(session.to_sym)
      end

      def strategy_for(session:, day_type:, regime:)
        return nil unless tradable?(session: session, day_type: day_type, regime: regime)

        ExpiryTrendV1
      end
    end
  end
end

module BacktestEngine
  class Metrics
    Trade = Struct.new(
      :entry_time,
      :exit_time,
      :side,
      :option_type,
      :strike,
      :entry_price,
      :exit_price,
      :pnl,
      :pnl_pct,
      :day_type,
      :session,
      :regime,
      keyword_init: true
    )

    attr_reader :trades

    def initialize
      @trades = []
    end

    def record_trade(trade)
      return if trade.nil?

      if trade.is_a?(Numeric)
        trades << Trade.new(pnl: trade.to_f)
        return
      end

      trades << trade
    end

    def total_pnl
      trades.sum { |t| t.pnl.to_f }
    end

    def average_pnl
      return 0.0 if trades.empty?

      total_pnl / trades.size
    end

    def winning_rate
      return 0.0 if trades.empty?

      wins = trades.count { |t| t.pnl.to_f.positive? }
      (wins.to_f / trades.size) * 100.0
    end

    def trades_by(key)
      unless Trade.members.include?(key.to_sym)
        raise ArgumentError, "Unknown trade field: #{key}. Supported: #{Trade.members.join(', ')}"
      end

      trades.group_by { |t| t.public_send(key) }
    end

    # Backwards compatibility for older callers/tests
    def trade_pnls
      trades.map { |t| t.pnl.to_f }
    end
  end
end


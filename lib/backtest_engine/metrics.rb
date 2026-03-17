module BacktestEngine
  class Metrics
    attr_reader :trade_pnls

    def initialize
      @trade_pnls = []
    end

    def record_trade(pnl)
      return if pnl.nil?

      trade_pnls << pnl.to_f
    end

    def total_pnl
      trade_pnls.sum
    end

    def average_pnl
      return 0.0 if trade_pnls.empty?

      total_pnl / trade_pnls.size
    end

    def winning_rate
      return 0.0 if trade_pnls.empty?

      wins = trade_pnls.count { |pnl| pnl.positive? }
      (wins.to_f / trade_pnls.size) * 100.0
    end
  end
end


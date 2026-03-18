# frozen_string_literal: true

require "spec_helper"
require "time"

RSpec.describe BacktestEngine::BatchRunner do
  def candle(ts, o, h, l, c)
    BacktestEngine::Market::Candle.new(
      timestamp: ts,
      open: o,
      high: h,
      low: l,
      close: c,
      volume: 1000
    )
  end

  def make_day(t0, option_closes)
    index_candles = option_closes.each_with_index.map do |_c, i|
      candle(t0 + i * 60, 100 + i, 102 + i, 99 + i, 101 + i)
    end
    option_data = {
      ["ATM", :call] => index_candles.each_with_index.map do |c, i|
        { timestamp: c.timestamp, close: option_closes[i].to_f, iv: 20 }
      end
    }
    {
      index_candles: index_candles,
      option_data: option_data,
      day_type: :normal
    }
  end

  describe ".run" do
    it "runs two days and merges trades into one Metrics" do
      t1 = Time.parse("2025-01-02 12:00:00")
      t2 = Time.parse("2025-01-03 12:00:00")
      day1 = make_day(t1, [80, 90, 100, 120])
      day2 = make_day(t2, [85, 95, 105, 125])

      result = described_class.run(
        days: [day1, day2],
        strategy_class: BacktestEngine::Strategies::ExpiryTrendV1,
        starting_capital: 100_000,
        lot_size: 50
      )

      expect(result).to be_a(described_class::Result)
      expect(result.metrics).to be_a(BacktestEngine::Metrics)
      expect(result.results.size).to eq(2)
      expect(result.metrics.trades.size).to eq(result.results.sum { |r| r.metrics.trades.size })
    end

    it "passes day_type per day to BacktestSession" do
      t1 = Time.parse("2025-01-02 12:00:00")
      day_normal = make_day(t1, [80, 90, 100, 100])
      day_normal[:day_type] = :normal
      day_expiry = make_day(t1 + 86_400, [80, 90, 100, 100])
      day_expiry[:day_type] = :expiry

      result = described_class.run(
        days: [day_normal, day_expiry],
        strategy_class: BacktestEngine::Strategies::ExpiryTrendV1,
        starting_capital: 100_000,
        lot_size: 50
      )

      expect(result.results.size).to eq(2)
    end
  end
end

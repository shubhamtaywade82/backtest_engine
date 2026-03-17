require "spec_helper"

RSpec.describe BacktestEngine::Market::CandleSeries do
  let(:candles) do
    [
      BacktestEngine::Market::Candle.new(
        timestamp: Time.at(1),
        open: 100,
        high: 105,
        low: 99,
        close: 104,
        volume: 10
      ),
      BacktestEngine::Market::Candle.new(
        timestamp: Time.at(2),
        open: 104,
        high: 108,
        low: 103,
        close: 107,
        volume: 15
      ),
      BacktestEngine::Market::Candle.new(
        timestamp: Time.at(3),
        open: 107,
        high: 110,
        low: 106,
        close: 109,
        volume: 20
      )
    ]
  end

  subject(:series) { described_class.new(candles) }

  it "exposes candles and size" do
    expect(series.size).to eq(3)
    expect(series.last).to be_a(BacktestEngine::Market::Candle)
  end

  it "computes ema without raising errors" do
    expect(series.ema(2).size).to eq(3)
  end

  it "detects structure array" do
    expect(series.structure).to all(satisfy { |val| %i[bullish bearish range].include?(val) })
  end
end


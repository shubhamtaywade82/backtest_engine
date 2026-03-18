# frozen_string_literal: true

require "spec_helper"
require "time"

RSpec.describe BacktestEngine::Market::CandleSeries do
  def candle(ts, close: 100.0, volume: 0)
    BacktestEngine::Market::Candle.new(
      timestamp: ts,
      open: close,
      high: close,
      low: close,
      close: close,
      volume: volume
    )
  end

  describe "#volume_spike?" do
    context "when volume is unavailable (all zeros)" do
      it "returns true so the volume filter does not block" do
        t0 = Time.parse("2025-01-02 09:15:00")
        candles = 30.times.map { |i| candle(t0 + i * 60, volume: 0) }
        series = described_class.new(candles)

        expect(series.volume_spike?(25, factor: 1.2, period: 10)).to eq(true)
      end
    end

    context "when volume is present" do
      it "detects spikes relative to the moving average window" do
        t0 = Time.parse("2025-01-02 09:15:00")
        volumes = [100] * 10 + [500]
        candles = volumes.each_with_index.map do |v, i|
          candle(t0 + i * 60, volume: v)
        end
        series = described_class.new(candles)

        expect(series.volume_spike?(10, factor: 1.5, period: 10)).to eq(true)
      end
    end
  end
end

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


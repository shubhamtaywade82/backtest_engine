# frozen_string_literal: true

require "spec_helper"

RSpec.describe BacktestEngine::Strategies::Router do
  describe "#tradable?" do
    it "returns true for normal day S2 and trend_bull" do
      expect(described_class.new.tradable?(session: :s2, day_type: :normal, regime: :trend_bull)).to be true
    end

    it "returns true for normal day S4 and trend_bear" do
      expect(described_class.new.tradable?(session: :s4, day_type: :normal, regime: :trend_bear)).to be true
    end

    it "returns true for expiry day E4 and trend_bull" do
      expect(described_class.new.tradable?(session: :e4, day_type: :expiry, regime: :trend_bull)).to be true
    end

    it "returns false for expiry day E2" do
      expect(described_class.new.tradable?(session: :e2, day_type: :expiry, regime: :trend_bull)).to be false
    end

    it "returns false for chop regime" do
      expect(described_class.new.tradable?(session: :s2, day_type: :normal, regime: :chop)).to be false
    end

    it "returns false for normal day S3" do
      expect(described_class.new.tradable?(session: :s3, day_type: :normal, regime: :trend_bull)).to be false
    end
  end

  describe "#strategy_for" do
    it "returns ExpiryTrendV1 when tradable" do
      expect(described_class.new.strategy_for(session: :s2, day_type: :normal, regime: :trend_bull)).to eq(BacktestEngine::Strategies::ExpiryTrendV1)
    end

    it "returns nil when not tradable" do
      expect(described_class.new.strategy_for(session: :s3, day_type: :normal, regime: :trend_bull)).to be_nil
    end
  end
end

require "spec_helper"
require "time"

RSpec.describe BacktestEngine::Strategies::ExpiryTrendV1 do
  let(:context) do
    {
      time: Time.parse("12:00"),
      structure: :bullish,
      htf_bias: :bullish,
      pullback: true,
      volume_spike: true
    }
  end

  it "generates buy call signal for bullish context" do
    result = described_class.new(context: context).call

    expect(result[:action]).to eq(:buy)
    expect(result[:option_type]).to eq(:call)
    expect(result[:strike]).to eq(:atm)
  end

  it "skips outside time window" do
    context[:time] = Time.parse("10:00")

    result = described_class.new(context: context).call

    expect(result[:action]).to eq(:skip)
    expect(result[:reason]).to match(/Outside time window/)
  end
end


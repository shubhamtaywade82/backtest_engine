#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "dotenv/load"

require "backtest_engine"

begin
  BacktestEngine::DhanConfiguration.configure_with_env_or_token_endpoint
rescue KeyError, LoadError => e
  warn "DhanHQ configuration skipped: #{e.message}"
end

def print_section(title)
  puts
  puts "=" * 90
  puts title
  puts "=" * 90
end

def print_result(label, result)
  print_section(label)
  puts "Trades: #{result.metrics.trades.size}"
  puts "Skip reasons:"
  result.metrics.skip_reasons.sort_by { |k, _v| k }.each do |reason, count|
    puts "  - #{reason}: #{count}"
  end
  puts "Analytics summary:"
  pp BacktestEngine::Analytics::TradeAnalytics.from_result(result).summary
end

def run_session(index_candles:, option_data:, starting_capital:, lot_size:, **opts)
  BacktestEngine::BacktestSession
    .new(
      index_candles: index_candles,
      option_data: option_data,
      starting_capital: starting_capital,
      lot_size: lot_size
    )
    .run(BacktestEngine::Strategies::ExpiryTrendV1, **opts)
end

from = "2025-01-02 09:15:00"
to = "2025-01-31 15:30:00"
expiry_code = 1

starting_capital = 100_000
lot_size = 65

print_section("Loading data (NIFTY, interval=1m, from=#{from}, to=#{to}, expiry_code=#{expiry_code})")

index_candles = BacktestEngine::Data::IndexLoader.fetch(
  interval: 1,
  from: from,
  to: to,
  security_id: BacktestEngine::Data::IndexLoader::NIFTY_SECURITY_ID
)

option_data = BacktestEngine::Data::OptionsLoader.fetch(
  interval: 1,
  from: from,
  to: to,
  expiry_code: expiry_code,
  security_id: BacktestEngine::Data::IndexLoader::NIFTY_SECURITY_ID,
  strikes: BacktestEngine::Data::OptionsLoader::DEFAULT_STRIKES
)

puts "Index candles: #{index_candles.size}"
puts "Option series keys: #{option_data.keys.size}"
puts "Example option series lengths:"
option_data.keys.first(3).each do |key|
  puts "  - #{key.inspect}: #{option_data[key].size}"
end

result = run_session(
  index_candles: index_candles,
  option_data: option_data,
  starting_capital: starting_capital,
  lot_size: lot_size,
  day_type: :normal,
  structure_engine: :v2,
  regime_scorer: true,
  strategy_router: false
)
print_result("Single run (day_type=:normal, router=false)", result)

days = [{ index_candles: index_candles, option_data: option_data, day_type: :normal }]

batch = BacktestEngine::BatchRunner.run(
  days: days,
  strategy_class: BacktestEngine::Strategies::ExpiryTrendV1,
  starting_capital: starting_capital,
  lot_size: lot_size,
  structure_engine: :v2,
  regime_scorer: true,
  strategy_router: true
)

print_section("Batch summary (day_type=:normal in days, router=true)")
pp BacktestEngine::Analytics::TradeAnalytics.from_metrics(batch.metrics).summary

param_grid = [
  { day_type: :normal },
  { day_type: :expiry }
]

results = BacktestEngine::Optimizer.run(
  days: days,
  strategy_class: BacktestEngine::Strategies::ExpiryTrendV1,
  param_grid: param_grid,
  starting_capital: starting_capital,
  lot_size: lot_size,
  objective: :expectancy,
  structure_engine: :v2,
  regime_scorer: true,
  strategy_router: true
)

print_section("Optimizer results (objective=:expectancy, router=true)")
results.each do |r|
  puts "- params=#{r.params.inspect} summary=#{r.analytics.summary.inspect}"
end

result = run_session(
  index_candles: index_candles,
  option_data: option_data,
  starting_capital: starting_capital,
  lot_size: 50,
  day_type: :expiry,
  structure_engine: :v2,
  regime_scorer: true,
  strategy_router: true,
  indicator_params: {
    pullback_ema_period: 20,
    volume_spike_factor: 1.15,
    volume_spike_period: 10
  }
)
print_result("Single run (day_type=:expiry, router=true, indicator_params tuned)", result)

result = run_session(
  index_candles: index_candles,
  option_data: option_data,
  starting_capital: starting_capital,
  lot_size: 50,
  day_type: :expiry,
  structure_engine: :v2,
  regime_scorer: true,
  strategy_router: false,
  indicator_params: { volume_spike_factor: 1.15, volume_spike_period: 10 }
)
print_result("Single run (day_type=:expiry, router=false, volume params tuned)", result)


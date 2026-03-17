## Backtest Engine

Index‑driven options backtesting engine for NIFTY using DhanHQ v2 data.

### High‑level design

- **Index Engine**: Iterates index candles and derives structure/bias.
- **Option Mapper**: Maps index state + spot to strikes and option candles.
- **Strategy Engine**: Pluggable strategy objects that generate signals.
- **Execution Engine**: Simulates fills, slippage, theta, and PnL with lot sizes.
- **Runner**: Orchestrates the backtest over a date range.

The engine is intentionally framework‑free and can be mounted into
`algo_scalper_api` or any other app.

### Installation (local dev)

```bash
bundle install
rspec
```

### Minimal usage example

```ruby
require "backtest_engine"

index_candles = [...]  # array of hashes with :timestamp, :open, :high, :low, :close, :volume
option_data   = {...}  # structured option candles per strike/type

runner = BacktestEngine::Runner.new(
  index_candles: index_candles,
  option_data: option_data
)

result = runner.run
puts result.total_pnl
```

### Runnable example – NIFTY intraday options

This example assumes:

- `dhan_hq` gem is available (from `dhanhq-client` repo or RubyGems).
- `DHAN_CLIENT_ID` and `DHAN_ACCESS_TOKEN` (or token endpoint envs) are set.

```ruby
require "backtest_engine"
require "dhan_hq"

# Configure DhanHQ (ENV, token endpoint, or both)
BacktestEngine::DhanConfiguration.configure_with_env_or_token_endpoint

# 1. Load NIFTY index candles (1‑minute) for a single expiry day
index_candles = DhanHQ::Models::HistoricalData.intraday(
  security_id: "13",          # NIFTY index
  exchange_segment: "IDX_I",
  instrument: "INDEX",
  interval: "1",
  from_date: "2024-02-01",
  to_date: "2024-02-01"
)

# 2. Load expired NIFTY options data (ATM calls for that day)
expired = DhanHQ::Models::ExpiredOptionsData.fetch(
  security_id: 13,
  exchange_segment: "NSE_FNO",
  instrument: "OPTIDX",
  expiry_flag: "WEEK",
  expiry_code: 0,
  strike: "ATM",
  drv_option_type: "CALL",
  interval: "1",
  from_date: "2024-02-01",
  to_date: "2024-02-01"
)

atm_call_candles = expired.to_candles("CALL")

option_data = {
  call: {
    atm_call_candles.first[:strike] => atm_call_candles
  },
  put: {}
}

runner = BacktestEngine::Runner.new(
  index_candles: index_candles,
  option_data: option_data,
  lot_size: 50 # adjust per historical lot size
)

metrics = runner.run
puts "NIFTY total PnL: #{metrics.total_pnl.round(2)}"
```

### Runnable example – SENSEX intraday options

Switch the underlying and lot size; the pattern is identical:

```ruby
require "backtest_engine"
require "dhan_hq"

BacktestEngine::DhanConfiguration.configure_with_env_or_token_endpoint

# Replace with the correct SENSEX security_id for your instruments
sensex_security_id = "12345"

index_candles = DhanHQ::Models::HistoricalData.intraday(
  security_id: sensex_security_id,
  exchange_segment: "IDX_I",
  instrument: "INDEX",
  interval: "1",
  from_date: "2024-02-01",
  to_date: "2024-02-01"
)

expired = DhanHQ::Models::ExpiredOptionsData.fetch(
  security_id: sensex_security_id.to_i,
  exchange_segment: "NSE_FNO",
  instrument: "OPTIDX",
  expiry_flag: "WEEK",
  expiry_code: 0,
  strike: "ATM",
  drv_option_type: "CALL",
  interval: "1",
  from_date: "2024-02-01",
  to_date: "2024-02-01"
)

atm_call_candles = expired.to_candles("CALL")

option_data = {
  call: {
    atm_call_candles.first[:strike] => atm_call_candles
  },
  put: {}
}

runner = BacktestEngine::Runner.new(
  index_candles: index_candles,
  option_data: option_data,
  lot_size: 20 # example SENSEX lot size; use actual
)

metrics = runner.run
puts "SENSEX total PnL: #{metrics.total_pnl.round(2)}"
```


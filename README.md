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


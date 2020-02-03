# Returner

Returner is a sample Elixir/Phoenix project that shows the past year returns for a bundle of stocks.

## Installation

  * Clone the repo
  * Sign up for an [Alpha Vantage API key](https://www.alphavantage.co/support/#api-key)
  * Create `config/test.secret.exs` and `config/dev.secret.exs` using the API key and samples
  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Architecture

* `Returner` exposes a simple API -- `fetch_returns/0`.
  * On app startup, `Returner` fetches the returns for the past year and caches them
* `ReturnerWeb` handles web requests

## Testing

* By default the test suite doesn't run any tests that query the Alpha Vantage API
* To run external tests, do `mix test --include external`

## Limitations

* The Alpha Vantage API's free plan is rate-limited to five requests per minute

## TODO

- Update the returns cache with new returns every evening after market close.
- Cache the returns in an external database or memory store, so that they aren't lost when the app shuts down
- Create a deployment strategy

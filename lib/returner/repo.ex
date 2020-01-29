defmodule Returner.Repo do
  use Ecto.Repo,
    otp_app: :returner,
    adapter: Ecto.Adapters.Postgres
end

defmodule IdleClicker.Repo do
  use Ecto.Repo,
    otp_app: :idle_clicker,
    adapter: Ecto.Adapters.Postgres
end

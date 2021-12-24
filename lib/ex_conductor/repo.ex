defmodule ExConductor.Repo do
  use Ecto.Repo,
    otp_app: :ex_conductor,
    adapter: Ecto.Adapters.Postgres
end

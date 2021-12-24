# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExConductor.Repo.insert!(%ExConductor.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

[
  %{
    email: "michael@test.com",
    password: "password12345"
  },
  %{
    email: "lauren@test.com",
    password: "password12345"
  },
  %{
    email: "jeffrey@test.com",
    password: "password12345"
  },
  %{
    email: "adam@test.com",
    password: "password12345"
  }
]
|> Enum.map(&ExConductor.Accounts.register_user/1)

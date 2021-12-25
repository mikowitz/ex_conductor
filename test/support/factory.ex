defmodule ExConductor.Factory do
  use ExMachina.Ecto, repo: ExConductor.Repo

  alias ExConductor.Accounts.User

  def user_factory do
    attrs = %{
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: "password12345"
    }

    %User{}
    |> User.registration_changeset(attrs)
    |> Ecto.Changeset.apply_changes()
  end

  def user_with_violin_factory do
    struct!(
      user_factory(),
      %{
        instruments: ["violin"]
      }
    )
  end
end

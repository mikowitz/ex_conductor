defmodule ExConductor.Repo.Migrations.AddInstrumentsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:instruments, {:array, :string}, default: [])
    end
  end
end

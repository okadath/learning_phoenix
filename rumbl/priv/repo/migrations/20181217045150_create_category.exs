defmodule Rumbl.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories) do
    	#agregamos lo ultimo apra que no sea nula
      add :name, :string, null: false

      timestamps()
    end
    #para que sean unicas
    create unique_index(:categories, [:name])
  end
end

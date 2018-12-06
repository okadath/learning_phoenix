defmodule Rumbl .User do
    #para el hardcodeed lo agregamos como un hash
    #defstruct [:id, :name, :username, :password]
    
    use Rumble.Web, :model
    
    
    def changeset(model, params \\ :empty) do
        model
        |> cast(params, ~w(name username), [])
        |> validate_length(:username, min: 1, max: 20)
        #agregar validacion si se hacen usuarios unicos en la migracion
        |> unique_constraint(:username, name: :users_username_index)
    end
    
    schema "users" do
        field :name, :string
        field :username, :string
        field :password, :string, virtual: true
        field :password_hash, :string
        timestamps()
    end
    

    
    
end
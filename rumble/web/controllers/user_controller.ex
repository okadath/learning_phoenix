defmodule Rumble.UserController do
    use Rumble.Web, :controller
    
    alias Rumbl.User
    #sin validacion
   #  def create(conn, %{"user" => user_params}) do
   #     changeset = User.changeset(%User{}, user_params)
  #      {:ok, user} = Repo.insert(changeset)
#        conn
#        |> put_flash(:info, "#{user.name} created!")
#        |> redirect(to: user_path(conn, :index))
 #   end
        
        
    def create(conn, %{"user" => user_params}) do
        changeset = User.changeset(%User{}, user_params)
        
        case Repo.insert(changeset) do
            {:ok, user} ->
                conn
                |> put_flash(:info, "#{user.name} created!")
                |> redirect(to: user_path(conn, :index))
            {:error, changeset} ->
                render(conn, "new.html", changeset: changeset)
        end
    end
    
    def new(conn, _params) do
    #le agregamos params, en el libro no vemina
        changeset = User.changeset(%User{},_params)
        render conn, "new.html", changeset: changeset
    end
    
    def index(conn, _params) do
        users = Repo.all(Rumbl.User)
        render conn, "index.html", users: users
    end
    
    def show(conn, %{"id" => id}) do
        user = Repo.get(Rumbl.User, id)
        render conn, "show.html", user: user
    end
    
   
end
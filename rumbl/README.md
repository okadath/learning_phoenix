notas ejecucion:
el ORM de elixir:
desde el iex:
importamos para poder llamarlos directamente

alias Rumbl.Repo
alias Rumbl.User
inserta:
Repo.insert(%User{
    name: "José", username: "josevalim", password_hash: "<3<3elixir"
    })


obtiene todos:
Repo.all(User)
obtiene 1:
Repo.get(User, 1)


el changeset maneja la informacion desde un struct en formularios a ecto

por eso lo añadimos al modelo, para entregar la info correctamente
en el changeset
cast(params, ~w(name username), [])
asi le indicamos que esos campos son forzosos
 el[] es por si los espacios vacios en el html se cuelan, hay que indicar 

mix phoenix.routes 
para ver las rutas 


 #se lo agregamos por que no venia en el libro
    {:plug_cowboy, "~> 1.0"}


el error del map :
 def new(conn, _params) do
    #le agregamos _params, en el libro no venia
        changeset = User.changeset(%User{},_params)



si el formulario no ocupa changeset(si no modifica info) entonces en ves de pasarselo le pasamos directamente el conn,generalmente en logins y busquedas

<%= form_for @conn, session_path(@conn, :create), [as: :session], fn f -> %>


por conn.assigns.current_user @current_user esta presente en todas las vistas 

link "Log out",
to:
session_path(@conn, :delete, @current_user),
method: "delete"
The link:
• Has the text Log out
• Links to the session_path path with the @conn connection, the :delete action,
and the @current_user argument
• Uses the HTTP delete method


en el logout en auth.delete si se quiere eliminar el id del usuario pero no la sesion se sustituye con

delete_session(conn, :user_id) .




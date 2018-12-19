Notas ejecucion:
===
**ORM Elixir:**

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
se lo agregamos por que no venia en el libro

	{:plug_cowboy, "~ > 1.0"}
el error del map :

	def new(conn, _ params) do
    #le agregamos _ params, en el libro no venia
    changeset = User.changeset(%User{},_ params)

si el formulario no ocupa changeset(si no modifica info)
 entonces en ves de pasarselo le pasamos directamente el conn,generalmente en logins y busquedas

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

	delete_session(conn, :user_id)

**scaffold:**

	mix phoenix.gen.html nombre_modelo plural_modelo campos

	mix phoenix.gen.html Video videos user_id:references:users 
	url:string title:string description:text

se deben hacer modificaciones en la autenticacion en el modelo de usuarios
y crear un nuevo scope en el router

despues de scaffoldear los videos migrar

	mix ecto.migrate
y modificar  user con 

	has_many :videos, Rumbl.Video
para poder accedes a la info:

	alias Rumbl.Repo
	alias Rumbl.User
	import Ecto.Query
asi los cargamos

	user = Repo.get_by!(User, username: "josevalim")
	user = Repo.preload(user, :videos)
	user.videos
asi creamos uno nuevo

	user = Repo.get_by!(User, username: "josevalim")
	attrs = %{title: "hi", description: "says hi", url: "example.com"}
	video = Ecto.build_assoc(user, :videos, attrs)
	video = Repo.insert!(video)
asi obtenemos todos los de un usuario

	query = Ecto.assoc(user, :videos)
	Repo.all(query)

casi todas las modificaciones se hacen en el nuevo video_controller, para acoplarse a todo lo anterior

**Validaciones**

generamos las categorias:

	mix phoenix.gen.model Category categories name:string
	#agregar a la migracion
	create unique_index(:categories, [:name])
	#esto se agrega en  el modelo para asegurar la relacion
	belongs_to :category, Rumbl.Category
luego migramos

	mix ecto.gen.migration add_category_id_to_video
	mix ecto.migrate

se debe de modificar el archivo de seeds para hardcodear los tipos de categorias, son fijas y luego correr: 

	mix run priv/repo/seeds.exs

querys para solicitar categorias por nombre:

	import Ecto.Query
	alias Rumbl.Repo
	alias Rumbl.Category
	Repo.all from c in Category,
		select: c.name
por nombre y ordenadas:

	Repo.all from c in Category,
	order_by: c.name,
	select: {c.name, c.id}
se puede construir paso a paso:	

	query = Category
	iex> query = from c in query, order_by: c.name
	iex> query = from c in query, select: {c.name, c.id}
	iex> Repo.all query

ya con las modificaciones en el modelo categorias
y el acceso desde videocontroller donde se plugeo el acceso a las categorias las cargamos en los CRUDs que deseemos

lo colocaremos en las vistas edit, new, y form se puede acceder en los htmls agregando @categories de su respectivo modo

Notas ejecucion:
===
Basico:
---

**Scaffold:**
base:

	mix phoenix.gen.html nombre_modelo plural_modelo campos
ejemplo:

	mix phoenix.gen.html Video videos user_id:references:users 
	url:string title:string description:text

se deben hacer modificaciones en la autenticacion en el modelo de usuarios
y crear un nuevo scope en el router

despues de scaffoldear los videos migrar

	mix ecto.migrate
y modificar  user con 

	has_many :videos, Rumbl.Video

generamos las categorias:

	mix phoenix.gen.model Category categories name:string
	#agregar a la migracion
	create unique_index(:categories, [:name])
	#esto se agrega en  el modelo para asegurar la relacion
	belongs_to :category, Rumbl.Category
luego creamos la migracion(solo si modificamos alguna tabla) y migramos, si no solo se migra

	mix ecto.gen.migration add_category_id_to_video
	mix ecto.migrate

los cambios y modificaciones de informacion se hacen en el changeset

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

**Scaffold:**

	mix phoenix.gen.html nombre_modelo plural_modelo campos

	mix phoenix.gen.html Video videos user_id:references:users 
	url:string title:string description:text

se deben hacer modificaciones en la autenticacion en el modelo de usuarios
y crear un nuevo scope en el router

despues de scaffoldear los videos migrar

	mix ecto.migrate
y modificar  user con 

	has_many :videos, Rumbl.Video
para poder acceder a la info:

	alias Rumbl.Repo
	alias Rumbl.User
	import Ecto.Query
asi los cargamos(se debe construir la asociacion cn preload o no jala!!!!!)

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

	import Ecto.Query
	alias Rumbl.Repo
	alias Rumbl.User
	username = "josevalim"
	Repo.one(from u in User, where: u.username == ^username)
+Repo.one->una fila
+from u in User leera del User schema.
+where: u.username == ^usernamedevolvera la columna  que u.username ==
^username . el operator ^ (pin operator) mantendremos ^username igual, este es el que queremos comprobar si esta en la DB.
+cuando select  es omitido regresa select: u

Es mas sencillo prevenir SQLinjection ya que las peticiones no son strings encadenados

solo los controladores pueden tener side effects para modificar el ambiente
leer y escribir datos en un socket(es side effect)

**Tipos de Queries:**

+ Keyword Syntax:

		Repo.one from u in User, select: count(u.id), where: ilike(u.username, ^"j%") 
		or ilike(u.username, ^"c%")
se puede separar:

		users_count = from u in User, select: count(u.id)
		j_users = from u in users_count, where: ilike(u.username, ^"%j%")

+ Pipe Syntax(para aplicaciones complejas, se pude indicar mas de un binding(la u)para hacer querys complejas):
	
		User |>
		select([u], count(u.id)) |>
		where([u], ilike(u.username, ^"j%") or ilike(u.username, ^"c%")) |>
		Repo.one()

no comprendo como se usan los query fragments, buscar en su documentacion :/

podemos construir la asociacion al vuelo:

	user = Repo.one from(u in User, limit: 1, preload: [:videos])

podemos crearla internamente:

	Repo.all from u in User, 
	join: v in assoc(u, :videos),
	join: c in assoc(v, :category),
	where: c.name == "Comedy",
	select: {u, v}

los constraints permiten manejar y prevenir errores por datos inconsistentes
pero debe ser manejado sengun las necesidades... cualquier duda al manejar bd volver a la pag 124

**Tests**

uno en especifico:

	mix test test/controllers/page_controller_test.exs:4

crear /rumbl/test/support/test_helpers.ex
bypassearemos el login para ahorrar logearnos siempre

Parte II
---

editar las vistas para ver videos
agregaremos un watch como view y controller, y su vista show para podernos asegurar que el resto del mundo pueda ver cualquier video
modificamos el router :

	get "/watch/:id", WatchController, :show

para compilar js:

	brunch build
	brunch build --production
	brunch watch

para crear jscripts hay que ponderlos en el app o crear nuevos 

**Slugs**
hacemos una migracion:

	mix ecto.gen.migration add_slug_to_video
la modificamos
	
	alter table(:videos) do
		add :slug, :string
	end
y migramos

	mix ecto.migrate

modificamos el modelo video para que un nuevo campo slug se genere automaticamente en el changeset del modelo
tambien modificaremos una implementacion de protocolo en el modelo video
me parece que el to_params modificado es el que proporciona la URI

pero tenemos un problema de casteo con el ID
en el libro crearon un nuevo tipo para ecto en lib/rumbl/permalink para poder acceder al ID(no entiendo por que no solo castearon o recortaron, lo que sea)
y lo agregaron como ID automatico para el campo video

**Channels**

Necesita internetpara cargar la info del video, si no no funcionan los sockets

Se realizaron varias modificaciones a los web/static/js para implementar el cliente desde javascript

los sockets manejan topicos, sobre estos van las conversaciones, creamos sus callbacks en web/channel

el video channel sera el manejador de los eventos del socket
el user solo los autentica y valida

handle_info callback is invoked whenever an Elixir message reaches the channel.
handle_in, This function will handle all incoming messages to a channel, pushed directly from the remote client.

	def handle_in("new_annotation", params, socket) do
	broadcast! socket, "new_annotation", %{
	user: %{username: "anon"},
	body: params["body"],
	at: params["at"]
	}
	{:reply, :ok, socket}
	end

broadcast! manda a todos:

	broadcast! socket,nombre_evento,carga(un mapa)

debe ser bien estructurado ya que todos los clientes lo recibiran, NO PASARLO AL VUELO!!!:

	asi NO:
	broadcast! socket, "new_annotation", 
	Map.put(params, "user", %{username: "anon"})

modificamos la plantilla de app para acceder a un token de autenticacion, modificamos el auth para crear el token al iniciar sesion

cambiams el usertoken y verificamos que se cumpla el lapso de vida del token


hacer anotaciones persistentes 189
creamos su tabla , modificamos el video chanel para manejar los nievos datos
manejamos la vista del usuario para desplegar la info

modificamos el join del video_channel para acceder a las anotaciones previas

creamos un annotation_view para desplegar cada mensaje individual en json:
render_one ya valida los nil
modificamos otra vez e video.js para que maneje los mensajes previos y agregue la hora del mensaje


para evitar desconexiones y mensajes dobles editamos de nuevo el videojs y el video channel para contar el ultimo mensaje visto y asi evitar recargar mensajes ya cargados

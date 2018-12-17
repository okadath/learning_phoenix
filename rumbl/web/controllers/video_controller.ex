defmodule Rumbl.VideoController do
  use Rumbl.Web, :controller

  alias Rumbl.Video
#agregado para validar entre nil y espacio en blanco
  plug :scrub_params, "video" when action in [:create, :update]

#con esto pasamos directamente el usuario logeado por que 
#lo requerimos mucho
  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  defp user_videos(user) do
    assoc(user, :videos)
  end
#=========================================
  #en estos reescribimos
  #asignamos un usuario a videos

  # def new(conn, _params) do
  #   changeset = Video.changeset(%Video{})
  #   render(conn, "new.html", changeset: changeset)
  # end
  def new(conn, _params, user) do
    changeset = 
    #antes de crear la accion
    #conn.assigns.current_user
    user
    |> build_assoc(:videos)
    |> Video.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  #agregamos el paso del usuario
  def create(conn, %{"video" => video_params}, user) do
    changeset = 
    #Video.changeset(%Video{}, video_params)
    user
    |> build_assoc(:videos)
    |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

#===============================
  #en estos usaremos la func. privada
  #user videos para solo mostrar 
  #los videos de un usuario dado
  def index(conn, _params, user) do
    #videos = Repo.all(Video)
    videos = Repo.all(user_videos(user))
    render(conn, "index.html", videos: videos)
  end

  def show(conn, %{"id" => id}, user) do
    #video = Repo.get!(Video, id)
    video = Repo.get!(user_videos(user), id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    #video = Repo.get!(Video, id)
    video = Repo.get!(user_videos(user), id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    #video = Repo.get!(Video, id)
    video = Repo.get!(user_videos(user), id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    #video = Repo.get!(Video, id)
    video = Repo.get!(user_videos(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end
end
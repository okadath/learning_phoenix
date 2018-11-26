defmodule Hello.HelloController do
	use Hello.Web, :controller
		# def world(conn,_params) do
	def world(conn,%{"name"=>name}) do
		#paso de parametros
		render conn, "world.html",names: name
	end
end
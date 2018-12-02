# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :rumble,
  ecto_repos: [Rumble.Repo]

# Configures the endpoint
config :rumble, Rumble.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7rbYeucX96yQxM4mAjkjcTCKO+krnIi5m9o2lMH13L4h1rcWF9KCYvmn+NxEcntU",
  render_errors: [view: Rumble.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Rumble.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

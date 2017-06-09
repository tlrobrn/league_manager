# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :league_manager,
  ecto_repos: [LeagueManager.Repo]

# Configures the endpoint
config :league_manager, LeagueManager.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KFtQXp/TVAxPMr9q2DW5UnMM4jSBedwhPbvX9c1PHBz8Lx5n2c0F/T0GAadwiN+V",
  render_errors: [view: LeagueManager.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LeagueManager.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Arc (image handling)
config :arc,
  storage: Arc.Storage.S3,
  bucket: "foos-summer-league-2017-06-09"

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

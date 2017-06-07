defmodule LeagueManager.Router do
  use LeagueManager.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LeagueManager do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/rules", PageController, :rules
    get "/register", TeamController, :new
    resources "/games", GameController, only: [:index, :edit, :update]
    post "/schedule", PageController, :schedule
    resources "/teams", TeamController, except: [:delete]
  end
end

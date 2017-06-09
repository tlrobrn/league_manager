# LeagueManager

Run locally

```
$ docker-compose up -d web
$ docker-compose run web mix do deps.get, compile
$ docker-compose run web mix ecto.create
$ docker-compose run web mix ecto.migrate
$ docker-compose run web npm config set strict-ssl false
$ docker-compose run web npm install
$ docker-compose restart web
```

Assuming all that goes well, you can visit `localhost:4000`.

# Naruto Unison

The next generation of Naruto Arena, built from the ground up in Haskell and Elm.

*Naruto* was created by Masashi Kishimoto, published by Pierrot Co., and licensed by Viz Media.

Currently pre-alpha and in active development. Nothing is guaranteed to be stable or fully functional.

![Character Select](static/img/screenshot/select.png)

![Game](static/img/screenshot/game.png)

![Changelog](static/img/screenshot/changelog.png)

## Installing

1. Install [Git](https://git-scm.com/downloads), [Stack](https://docs.haskellstack.org/en/stable/install_and_upgrade/), [PostgreSQL](https://www.postgresql.org/download/), and [NPM](https://www.npmjs.com/get-npm). Make sure all executables are added to your path.

2. Run `stack install yesod-bin`.

2. In the [elm](elm/) folder of the project, run `npm install`.

3. In the root directory of the project, run `stack build`.

4. Start up the PostgreSQL server.

5. Create a new database and add it to the PostgreSQL [pg_hba.conf](https://www.postgresql.org/docs/9.1/auth-pg-hba-conf.html) file.

6. Configure environment variables in [config/settings.yml](config/settings.yml) to point to the database.

## Running

To use a development web server, run `stack exec -- yesod devel` in the root directory of the project. Recompile the Elm frontend with `(cd elm && npm install)` whenever changes are made to the [elm](elm/) folder.

In order to run the server in production mode, which has significantly better performance, deploy it with [Keter](https://www.yesodweb.com/blog/2012/05/keter-app-deployment). It is recommended to use a standalone server for hosting the Keter bundle and PostgreSQL database. The only server requirement to host Keter bundles is the Keter binary itself, which may be compiled on another machine with GHC and copied over. Docker support is planned but not yet implemented.

## Model Syncing

After making changes that affect the JSON representation of a data structure transmitted to the client, run `stack run elm-bridge` to make the corresponding changes to the client's representations. Always run `(cd elm && npm install)` after altering code in the [elm](elm/) folder.

# Conjur Policy Generator Web UI

This UI makes it easy to generate policies interactively in your web browser.

The web UI is live here: https://cyberark.github.io/conjur-policy-generator

## Development

The web UI is implemented in Ruby, using the [Opal](https://opalrb.com)
source-to-source compiler to convert the source code into Javascript that runs
on the client. The page that gets served to the user is a static web app
requiring no server communication.

It uses [Bootstrap](https://getbootstrap.com) as its theme framework, and
[Inesita](https://inesita.fazibear.me) as its rendering framework and asset
packager.

### Create a dev environment using Docker

The web UI does not depend on Docker. If you prefer to develop without it, see
[below](#create-a-dev-environment-without-docker).

A convenient script is provided for you to set up an isolated dev environment
using Docker.

#### Dependencies

##### GNU/Linux

* Docker
* Docker Compose

Links to distro-specific instructions are
[here](https://docs.docker.com/install/#server).

##### macOS

[Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

##### Windows

[Docker for Windows](https://docs.docker.com/docker-for-windows/install/)

#### Start the dev environment

Run from the project root:

```sh-session
$ bin/dev
```

The script does the following:
* builds and fetches all depdendencies
* sets up a server running on [http://localhost:9292/](http://localhost:9292/)
* maps this directory into the container and sets up hot code reloading for
  rapid local development

#### Restart the dev server

Most code changes will be hot-reloaded automatically, but some types of changes
(like when modifying routes, adding new files or modifying the file structure,
or adding new dependencies) require a full server restart.

To do this, run from the project root:
```sh-session
$ docker-compose restart dev-server
```

### Create a dev environment without Docker

#### Dependencies

* [ruby](https://www.ruby-lang.org/en/documentation/installation/)
* [bundler](https://bundler.io/#getting-started)
* [latest release of conjur-policy-generator](https://github.com/cyberark/conjur-policy-generator/releases)

Put the release files in `src/ruby/`. Then install the gem dependencies:

```sh-session
$ cd web
$ bundle install
```

#### Start the dev environment

From `web` directory run:
```sh-session
$ bundle exec inesita server
```

Then visit [http://localhost:9292/](http://localhost:9292/)

![screen shot 2018-08-28 at 11 42 26](https://user-images.githubusercontent.com/35257365/44712161-d475e280-aab8-11e8-9a73-c44edb1963a4.png)

#### Shut down or restart the dev server

To disconnect from the server, close terminal window or interrupt the server
(<kbd>Ctrl</kbd>+<kbd>c</kbd>).

Most code changes will be hot-reloaded automatically, but some types of changes
(like when modifying routes, adding new files or modifying the file structure,
or adding new dependencies) require a full server restart.

To restart the server, interrupt it as described and then run `bundle exec
inesita server` again.

### Promote a new version of the web UI to production

Follow this process:

1. Create a branch in git with your changes
2. Run `bin/build-website` in the project root (requires Docker),
   or in the `web` folder run:
   ```sh-session
   $ bundle exec inesita build --force --destination-dir ../dist
   ```
3. Revert (some) changes in `docs/index.html`: by default, Inesita will build
   `index.html` with absolute paths, which you'll want to change to relative
   paths.
   
   Specifically
   * in the `link` with `href="/stylesheets.css"`, change to `href="stylesheets.css"`
   * `script` with `src="/application.js"`, change to `src="application.js"`
   
   GitHub pages wants relative paths but Inesita doesn't want to generate that
   way. It's something we can fix upstream given time and cooperation. For now I
   do it manually. We could automate it with a little sed script if we wanted,
   as well.
4. Add the contents of the `docs` folder to your git branch.
5. Create a pull request. When merged, GitHub Pages will automatically update
   the live app with the contents of the `docs` folder.

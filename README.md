# Conjur Policy Generator

It makes MAMLs!

## Testing

You can `npm install` and `npm test`, or you can use the Dockerized environment:

```shell
./build.sh
./test.sh
```

## Making MAMLs

You can `npm install` and `npm run generate`, or you can use the Dockerized environment:

```shell
./build.sh
./generate.sh
```

You can use the following options with `generate` to customize the output policy:

* `--users` (`-u`): number of users
* `--groups` (`-g`): number of groups
* `--usersPerGroup` (`-k`): number of members in each group

## Capabilities

`mom.humans (users, groups, usersPerGroup)` creates a MAML policy according to
the given parameters.

If the policy is small, it will be nice and readable, with users and groups like:

```sh-session
$ npm run generate -- -u2 -g2 -k0

> conjur-mom@1.0.0 generate /Users/ryan/dev/cyberark/conjur-mom
> node ./src/index.js "-u2" "-g2" "-k0"

---
- !user alice
- !user bob
- !group aardvark
- !group bobcat
```

If the policy is large, they will be appended with random strings to avoid collisions like so:

```sh-session
$ npm run generate -- -u2 -g200 -k0 | head -n9

> conjur-mom@1.0.0 generate /Users/ryan/dev/cyberark/conjur-mom
> node ./src/index.js "-u2" "-g200" "-k0"

---
- !user alice--5dc0e441-8fbf-4549-9bf8-718b64301c26
- !user bob--815bb209-c428-4e0b-a84f-4e15f97a7267
- !group aardvark--be5c77cc-bfb8-4e08-8821-20bafc4b4cb0
- !group bobcat--e135e2ca-74e9-4dfc-a5d2-1dc0e166df54
```

## Limitations

`mom` has no other generators or options. Here's a wish list:

* N databases with a url, username and password, and a secrets-users group, owned by a distinct group
* N applications with a layer and 10 secrets each, owned by a distinct group
* Grant each of N secrets-users database groups to one of the N application layers

# Conjur Policy Generator

It makes MAMLs!

## Testing

Details: [Testing](tests.md)

You can `bundle install` and `bundle exec rake test`, or you can use the Dockerized environment:

```shell
bin/build
bin/test
```

## Making MAMLs

Implementation: [Policy Generator](src/generator.md)

You can `bundle install` and `bundle exec rake generate`, or you can use the Dockerized environment:

```shell
bin/build
bin/generate
```

You can give three numbers to `generate` to customize the output policy:

* number of users
* number of groups
* number of users per group

For example, to generate a policy with 5 users, 2 groups, 3 users per group:

```shell
bin/build
bon/generate [5,2,3]
```

## Capabilities

[Conjur::PolicyGenerator::Humans](src/generator.md#humans-policy-generator)
creates a MAML policy according to the given parameters.

If the policy is small, it will be nice and readable, with users and groups like:

```sh-session
$ bundle exec rake generate[2,2,0]
---
- !user alice
- !user bob
- !group aardvark
- !group bobcat
```

If the policy is large, they will be appended with random strings to avoid
collisions like so:

```sh-session
$ bundle exec rake generate[2,200,0] | head -n5
---
- !user alice--13af8b89-2b9e-4925-8537-a6bb0b58c09b
- !user bob--f73ce8d5-6e6f-44ac-8bf1-6ea3e0a748bf
- !group aardvark--01ba5225-4e25-46a2-971b-1d84ac5cdc9c
- !group bobcat--200c7a21-3961-44bb-adcc-a64aa024c023
```

## Limitations

`generate` has no other generators or options. Here's a wish list:

* N databases with a url, username and password, and a secrets-users group, owned by a distinct group
* N applications with a layer and 10 secrets each, owned by a distinct group
* Grant each of N secrets-users database groups to one of the N application layers

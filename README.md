# Conjur Policy Generator

It makes MAMLs!

## Testing

Details: [Testing](tests.md)

You can `bundle install` and `bundle exec rake test`, or you can use the Dockerized environment:

```shell
bin/build
bin/test
```
## Web UI

Details: [Web-UI](web/README.md)

The web UI is live here: [https://cyberark.github.io/conjur-policy-generator][app-url]

[app-url]: https://cyberark.github.io/conjur-policy-generator

## Making MAMLs (policies)

Implementation: [Policy Generator](src/generator.md)

MAML is short for Machine Authorization Markup Language, and the output of each
policy generator is in MAML. Using a generator requires a few steps:

You can `bundle install` and `bundle exec rake generate`, or you can use the
Dockerized environment:

```shell
bin/build
bin/generate
```

The `generate` script uses the "Humans" generator described below.

For example, to generate a policy with 5 users, 2 groups, 3 users per group:

```shell
bin/build
bin/generate [5,2,3]
```

## Capabilities

### [Conjur::PolicyGenerator::Humans](src/generator.md#humans-policy-generator)

Creates a MAML policy containing people and groups.

If the policy is small, it will be nice and readable, with users and groups
like:

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

### [Conjur::PolicyGenerator::Secrets](src/generator.md#secrets-policy-generator)

Creates a MAML policy containing secrets (optionally with annotations.)

If the number of secrets & annotations per secret are small, it will look like
so:

```sh-session
$ bundle exec rake secrets[2,0]
---
- !variable hydrogen
- !variable lithium
$ bundle exec rake secrets[1,2]
---
- !variable
  id: hydrogen
  annotations:
    density: value
    color: value
```

If the policy is large, it will be appended with random strings to avoid
collisions:

```sh-session
$ bundle exec rake secrets[1000,0] | head -n5
---
- !variable hydrogen--e885ac44-8daa-46cd-a72f-86f31dd869be
- !variable lithium--7f604c73-c26d-485b-b8e9-34d68ddd5a64
- !variable sodium--83ae803d-f574-4b3f-ab87-43bd60270a8b
- !variable potassium--1a4be938-4fd3-4a35-850f-e7d56c7cc656
```

### [Conjur::PolicyGenerator::Template::SecretControl](src/generator.md#secret-control-template-generator)

Creates a MAML policy with nested sub-policies, suitable for providing
fine-grained control over sets of application secrets.

If the number of secrets & sets is small, it'll look like so:

```sh-session
$ bundle exec rake control_secrets[myapp,1,1]
---
- !policy
  id: myapp
  body:
    - !policy
      id: alfa
      body:
        # Secret Declarations
        - &secrets
          - !variable hydrogen
        
        # User & Manager Groups
        - !group secrets-users
        - !group secrets-managers
        - !permit
          role: !group secrets-users
          privileges: [ read, execute ]
          resources: *secrets
        - !permit
          role: !group secrets-managers
          privileges: [ read, execute, update ]
          resources: *secrets
```

If you want to include a hostfactory for automated enrollment of new hosts, you
can pass `true` as the last argument, like so:

```sh-session
$ bundle exec rake control_secrets[myapp,1,1,true]
---
- !policy
  id: myapp
  # [...same as before, plus...]
    # === Layer for Automated Secret Access ===
    - !policy
      id: hosts
      annotations:
        description: Layer & Host Factory for machines that can read secrets
      body:
        - !layer
        - !host-factory
    - !grant
      role: !group alfa/secrets-users
      member: !layer hosts
```

With a large number of secrets, or of secret sets, IDs will be appended with
random strings to ensure uniqueness:

```sh-session
$ bundle exec rake control_secrets[myapp,10,10] | head -n12
---
- !policy
  id: myapp
  body:
    - !policy
      id: alfa--822847c1-b57b-43bc-9ceb-b0f3c56681c1
      body:
        # Secret Declarations
        - &secrets
          - !variable hydrogen--745a35f7-f501-4963-9d35-7b32c36cc583
          - !variable lithium--cf1cdd49-ecbe-4925-8e2c-b538d9a44ccf
          - !variable sodium--f874fb97-1a84-4cea-b200-09eee4b8ca00
```

### [Conjur::PolicyGenerator::Template::Kubernetes](src/generator.md#kubernetes-template-generator)

Creates a template for controlling application secrets via authn-Kubernetes,
like the one in [our demo][k8s-demo].

[k8s-demo]: https://github.com/conjurdemos/kubernetes-conjur-demo/tree/master/policy/templates

It's a lot of text to paste here, so check it out in the [live app][app-url]
(select "Authn-Kubernetes" in the upper right hand corner) or check out the
demo, which has similar code.

In summary: it contains a few groups to enable separation of duties, then it has
a few policies to control app secrets, permitted identities, and the Conjur
certificate authority.

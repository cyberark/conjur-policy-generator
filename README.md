# Conjur Mom

It makes MAMLs!

## Testing

You can `npm install` and `npm test`, or you can use the Dockerized environment:

```shell
./build.sh
./test.sh
```

## Capabilities

`mom.humans (users, groups, usersPerGroup)` creates a MAML policy according to
the given parameters.

If the policy is small, it will be nice and readable, with users and groups like:

```
- !user alice
- !user bob
- !group aardvark
- !group bobcat
```

If the policy is large, they will be appended with random strings to avoid collisions like so:

```
- !user alice--36d442b7-33a6-4a9e-800f-b9e37edc902d
- !user bob--8ca288ad-cc29-420a-8579-ae9bd569953b
- !group aardvark--aa3fba89-3895-48c5-afd0-1bd012e25010
- !group bobcat--37302e9c-0453-4354-be15-33d1f3030744
```

## Limitations

`mom` has no other generators or options. Here's a wish list:

* N databases with a url, username and password, and a secrets-users group, owned by a distinct group
* N applications with a layer and 10 secrets each, owned by a distinct group
* Grant each of N secrets-users database groups to one of the N application layers

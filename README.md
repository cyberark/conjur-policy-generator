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

## Limitations

`mom.humans` can't create large policies yet. At the moment, "large" is defines
as a policy with >16 users or >3 groups. Addressing this shortcoming is a top
priority.

`mom` has no other generators or options. Here's a wish list:

* N databases with a url, username and password, and a secrets-users group, owned by a distinct group
* N applications with a layer and 10 secrets each, owned by a distinct group
* Grant each of N secrets-users database groups to one of the N application layers

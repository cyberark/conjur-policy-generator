# loadtest

The scripts in this directory allow us to test policy load times for Conjur 4 and 5.
Both services are launched via docker-compose.

## Usage

### Conjur v5

TODO

### Conjur v4

./test.v4.sh policy.m.yml

## Test policies

Test policies are split up by size. We want to test the load times for policies of different sizes.

### Small

`policy.small.yml` - 10 users, 3 groups, 1 user per group

### Medium

`policy.medium.yml` - 100 users, 30 groups, 10 users per group

### Large

`policy.large.yml` - 1000 users, 300 groups, 100 users per group

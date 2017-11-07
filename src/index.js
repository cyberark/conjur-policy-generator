const parseArgs = require('minimist')
const mom = require('./mom')
const humans = mom.humans

const parseOptions = {
  alias: {
    u: 'users',
    g: 'groups',
    k: 'usersPerGroup'
  },
  default: {
    users: 2,
    groups: 1,
    usersPerGroup: 1
  }
}

const {users, groups, usersPerGroup} = parseArgs(process.argv.slice(2), parseOptions)

console.log(humans(users, groups, usersPerGroup))

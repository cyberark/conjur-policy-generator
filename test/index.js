/* eslint-env mocha */

var assert = require('assert')
var mom = require('../src/mom')

const humansPolicy211 = `---
- !user alice
- !user bob
- !group aardvark
- !grant
  role: !group aardvark
  member: !user alice
`

const humansPolicy424 = `---
- !user alice
- !user bob
- !user carol
- !user dan
- !group aardvark
- !group bobcat
- !grant
  role: !group aardvark
  members: [ !user alice, !user bob, !user carol, !user dan ]
- !grant
  role: !group bobcat
  members: [ !user alice, !user bob, !user carol, !user dan ]
`

const humansPolicy525 = `---
- !user alice
- !user bob
- !user carol
- !user dan
- !user erin
- !group aardvark
- !group bobcat
- !grant
  role: !group aardvark
  members:
    - !user alice
    - !user bob
    - !user carol
    - !user dan
    - !user erin
- !grant
  role: !group bobcat
  members:
    - !user alice
    - !user bob
    - !user carol
    - !user dan
    - !user erin
`

describe('Conjur mom', () => {
  describe('#humans', () => {
    it('yields default policy', () => {
      assert.equal(mom.humans(), humansPolicy211)
    })
    it('yields policy for 4 users, 2 groups, 4 users per group with inline lists', () => {
      assert.equal(mom.humans(4, 2, 4), humansPolicy424)
    })
    it('yields policy for 5 users, 2 groups, 5 users per group with vertical lists', () => {
      assert.equal(mom.humans(5, 2, 5), humansPolicy525)
    })
  })
})

/* eslint-env mocha */

var assert = require('assert')
var mom = require('../src/mom')

const defaultHumansPolicy = `---
- !user alice
- !user bob
- !group aardvark
- !grant
  role: !group aardvark
  member: !user alice
`

describe('Conjur mom', () => {
  describe('#humans', () => {
    it('yields default policy', () => {
      assert.equal(mom.humans(), defaultHumansPolicy)
    })
  })
})

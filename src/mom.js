function humans (users = 2, groups = 1, usersPerGroup = 1) {
  return `---
- !user alice
- !user bob
- !group aardvark
- !grant
  role: !group aardvark
  member: !user alice
`
}

module.exports = {humans}

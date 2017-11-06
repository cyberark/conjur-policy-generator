function yaml (...children) {
  return `---
${verticalList(...children)}
`
}

function verticalList (...children) {
  return children.map(child => `- ${child}`).join('\n')
}

function user (name) {
  return `!user ${name}`
}

function group (name) {
  return `!group ${name}`
}

function grant (role, member) {
  return `!grant
  role: ${role}
  member: ${member}`
}

function humans (users = 2, groups = 1, usersPerGroup = 1) {
  return yaml(
    user('alice'),
    user('bob'),
    group('aardvark'),
    grant(group('aardvark'), user('alice'))
  )
}

module.exports = {humans}

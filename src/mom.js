const constants = require('./constants')

function indent (text, number = 2, char = ' ') {
  return text.split('\n')
    .map(line => `${char.repeat(number)}${line}`)
    .join('\n')
}

function yaml (...children) {
  return `---
${verticalList(...children)}
`
}

function verticalList (...children) {
  return children.map(child => `- ${child}`).join('\n')
}

function inlineList (...children) {
  return `[ ${children.join(', ')} ]`
}

function user (name) {
  return `!user ${name}`
}

function group (name) {
  return `!group ${name}`
}

function grant (role, ...members) {
  const renderMembers = () => {
    if (members.length === 1) {
      return `member: ${members[0]}`
    } else if (members.length <= 4) {
      return `members: ${inlineList(...members)}`
    } else {
      return `members:\n${indent(verticalList(...members))}`
    }
  }
  return `!grant
  role: ${role}
${indent(renderMembers())}`
}

function humans (users = 2, groups = 1, usersPerGroup = 1) {
  const userStrings = Array(users).fill().map((_, index) => constants.HUMAN_NAMES[index])
  const groupStrings = Array(groups).fill().map((_, index) => constants.ANIMAL_NAMES[index])
  const grantObjects = groupStrings.map(group => {
    return {
      role: group,
      members: userStrings.slice(0, usersPerGroup)
    }
  })

  return yaml(
    ...(userStrings.map(name => user(name))),
    ...(groupStrings.map(name => group(name))),
    ...(grantObjects.map(data => grant(group(data.role), ...(data.members.map(name => user(name))))))
  )
}

module.exports = {humans}

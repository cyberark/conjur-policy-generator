const constants = require('./constants')
const uuid = require('uuid/v4')

function indent (text, number = 2, char = ' ') {
  return text.split('\n')
    .map(line => `${char.repeat(number)}${line}`)
    .join('\n')
}

function makeUnique (string) {
  return `${string}--${uuid()}`
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
  const numUserNames = constants.HUMAN_NAMES.length
  const numGroupNames = constants.ANIMAL_NAMES.length
  const bigPolicy = users > numUserNames || groups > numGroupNames
  const transform = string => bigPolicy ? makeUnique(string) : string

  const userStrings = Array(users).fill()
        .map((_, index) => transform(constants.HUMAN_NAMES[index % numUserNames]))
  const groupStrings = Array(groups).fill()
        .map((_, index) => transform(constants.ANIMAL_NAMES[index % numGroupNames]))
  const grantObjects = usersPerGroup > 0 ? groupStrings.map(group => {
    return {
      role: group,
      members: userStrings.slice(0, usersPerGroup)
    }
  }) : []

  return yaml(
    ...(userStrings.map(name => user(name))),
    ...(groupStrings.map(name => group(name))),
    ...(grantObjects.map(data => grant(group(data.role), ...(data.members.map(name => user(name))))))
  )
}

module.exports = {humans}

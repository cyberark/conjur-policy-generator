# Policy Generator

Generates a Conjur security policy using Machine Authorization Markup Languate
(MAML) and a set of provided parameters.

The generated policy is intended to be useful for testing, training, and proof
of concept applications.

###### file:ruby/generator.rb
```ruby
module Conjur
  module PolicyGenerator
    extend self

    <<Helpers>>
    class Humans
      <<Humans Policy Generator>>
    end

    class Secrets
      <<Secrets Policy Generator>>
    end
  end
end
```

###### Helpers

To generate MAML, we use a bunch of rendering helpers. These are pure functions
which take some structure and return MAML policy text.

```ruby
def indent text, number = 2, char = ' '
  text.split("\n")
    .map! { |line| "#{char*number}#{line}" }
    .join("\n")
end

require 'securerandom'
def makeUnique string
  "#{string}--#{SecureRandom.uuid}"
end

def verticalList *children
  children.map { |child| "- #{child}" }
    .join("\n")
end

def verticalHash **pairs
  pairs.map { |key, val| "#{key}: #{val}" }
    .join("\n")
end

def inlineList *children
  "[ #{children.join ', '} ]"
end

def yaml *children
  <<~YAML
    ---
    #{verticalList(*children)}
  YAML
end

def user name
  "!user #{name}"
end

def group name
  "!group #{name}"
end

def grant role, *members
  def renderMembers members
    if members.length == 1
      "member: #{members.first}"
    elsif members.length <= 4
      "members: #{inlineList(*members)}"
    else
      "members:\n#{indent(verticalList(*members))}"
    end
  end

  result = <<~GRANT
    !grant
      role: #{role}
    #{indent renderMembers members}
  GRANT

  result.chop
end

def variable name, **annotations
  return "!variable #{name}" if annotations.length == 0
  result = <<~VARIABLE
    !variable
      id: #{name}
      annotations:
    #{indent verticalHash(**annotations), 4}
  VARIABLE

  result.chop
end
```

###### Humans Policy Generator

```ruby
require_relative './constants'
include Conjur::PolicyGenerator

def initialize users = 2, groups = 1, usersPerGroup = 1
  @users = users
  @groups = groups
  @usersPerGroup = usersPerGroup
end

def toMAML
  numUserNames = HUMAN_NAMES.length
  numGroupNames = ANIMAL_NAMES.length
  bigPolicy = @users > numUserNames || @groups > numGroupNames
  transform = -> string {
    if bigPolicy
      makeUnique string
    else
      string
    end
  }

  userStrings = (0..@users-1).map { |index| transform.(HUMAN_NAMES[index % numUserNames]) }
  groupStrings = (0..@groups-1).map { |index| transform.(ANIMAL_NAMES[index % numGroupNames]) }
  grantObjects = groupStrings.map { |group|
    {
      :role => group,
      :members => userStrings.slice(0, @usersPerGroup)
    }
  } unless @usersPerGroup <= 0
  grantObjects ||= []

  yaml(
    *userStrings.map { |name| user name },
    *groupStrings.map { |name| group name },
    *grantObjects.map { |data| grant group(data[:role]), *data[:members].map { |name| user name }}
  )
end
```

###### Secrets Policy Generator
```ruby
require_relative './constants'
include Conjur::PolicyGenerator

def initialize secrets = 1, annotationsPerSecret = 0
  @secrets = secrets
  @annotationsPerSecret = annotationsPerSecret
end

def toMAML
  numSecretNames = VARIABLE_NAMES.length
  numAnnotationNames = ANNOTATION_NAMES.length
  bigPolicy = @secrets > numSecretNames || @annotationsPerSecret > numAnnotationNames
  transform = -> string {
    if bigPolicy
      makeUnique string
    else
      string
    end
  }

  secretStrings = (0..@secrets-1).map { |index|
    transform.(VARIABLE_NAMES[index % numSecretNames])
  }
  annotationHash = Hash[
    *(0..@annotationsPerSecret-1).map { |index|
      [transform.(ANNOTATION_NAMES[index % numAnnotationNames]).to_sym, "value"]
    }.flatten]

  yaml(
    *secretStrings.map { |name| variable name, **annotationHash }
  )
end
```

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
  bigPolicy = @users > numUserNames or @groups > numGroupNames
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

  yaml(
    *userStrings.map { |name| user name },
    *groupStrings.map { |name| group name },
    *grantObjects.map { |data| grant group(data[:role]), *data[:members].map { |name| user name }}
  )
end
```

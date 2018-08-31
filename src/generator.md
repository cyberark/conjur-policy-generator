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

    module Template
      class SecretControl
        <<Secret Control Template Generator>>
      end
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

def taggedList tag, *children
  result = <<~LIST
  &#{tag}
  #{indent verticalList *children}
  LIST

  result.chomp
end

def verticalList *children
  result = ''
  children.each { |child|
    line_is_comment = (child.lstrip.empty? or child.lstrip.start_with? '#')
    result += "#{'- ' if not line_is_comment}" + child + "\n"
  }
  result.chomp
end

def verticalHash **pairs
  pairs.map { |key, val| "#{key}: #{val}" }
    .join("\n")
end

def inlineList *children
  "[ #{children.join ', '} ]"
end

def renderAnnotations hash
  <<~ANNOTATIONS
    annotations:
    #{indent verticalHash(**hash)}
  ANNOTATIONS
end

def comment text=nil
    "##{' ' + text if not text.nil?}"
end

def blank_line
  ''
end

def yaml *children
  <<~YAML
    ---
    #{verticalList *children}
  YAML
end

def policy name, *children, **annotations
  return "!policy #{name}" if children.empty? and annotations.empty?
  def renderBody children
    <<~BODY
      body:
      #{indent verticalList(*children)}
    BODY
  end

  result = <<~POLICY
    !policy
      id: #{name}
    #{indent renderAnnotations(annotations) if not annotations.empty?}
  POLICY
  result = result.chomp if annotations.empty?
  result += indent renderBody(children) if not children.empty?
  result.chomp
end

def user name
  "!user #{name}"
end

def group name
  "!group #{name}"
end

def host name
  "!host #{name}"
end

def layer name=nil
  "!layer#{' ' + name if not name.nil?}"
end

def host_factory name=nil
  "!host-factory#{' ' + name if not name.nil?}"
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

  result.chomp
end

def permit role, privileges, resource, plural=false
  result = <<~PERMIT
    !permit
      role: #{role}
      privileges: #{inlineList(*privileges)}
      resource#{'s' if plural}: #{resource}
  PERMIT

  result.chomp
end

def variable name, **annotations
  return "!variable #{name}" if annotations.empty?
  result = <<~VARIABLE
    !variable
      id: #{name}
    #{indent renderAnnotations annotations}
  VARIABLE

  result.chomp
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

## Policy Templates

These functions generate template policies designed to serve as the starting
point for produciton policies.

###### Secret Control Template Generator
```ruby
require_relative './constants'
include Conjur::PolicyGenerator

def initialize policy_name = 'example',
               secret_groups = 2,
               secrets_per_group = 2,
               include_hostfactory = false
  @policy_name = policy_name
  @secret_groups = secret_groups
  @secrets_per_group = secrets_per_group
  @include_hostfactory = include_hostfactory
end

def toMAML
  numSecretNames = VARIABLE_NAMES.length
  numGroupNames = NATO_ALPHABET.length
  bigPolicy = @secrets_per_group * @secret_groups > numSecretNames ||
              @secret_groups > numGroupNames
  transform = -> string {
    if bigPolicy
      makeUnique string
    else
      string
    end
  }

  secretStrings = (0..@secrets_per_group * @secret_groups-1).map { |index|
    transform.(VARIABLE_NAMES[index % numSecretNames])
  }
  groupStrings = (0..@secret_groups-1).map { |index|
    transform.(NATO_ALPHABET[index % numGroupNames])
  }

  def render_hosts groups
    [
      blank_line,
      comment('=== Layer for Automated Secret Access ==='),
      policy('hosts', layer, host_factory,
             description: 'Layer & Host Factory for machines that can read secrets'),
      groups.map { |group|
        grant(group("#{group}/secrets-users"),
              layer('hosts'))
      }
    ].flatten
  end

  yaml(
    policy(@policy_name,
           *secretStrings.each_slice(@secrets_per_group).with_index.map {
             |secrets, group_index|
             policy(groupStrings[group_index],
                    comment("Secret Declarations"),
                    taggedList('secrets', *secrets.map { |name| variable(name)}),
                    blank_line,
                    comment("User & Manager Groups"),
                    group('secrets-users'),
                    group('secrets-managers'),
                    permit(group('secrets-users'),
                           ['read','execute'],
                           '*secrets',
                           plural: true),
                    permit(group('secrets-managers'),
                           ['read','execute','update'],
                           '*secrets',
                           plural: true))
           },
           *(render_hosts(groupStrings) if @include_hostfactory)
          )
  )
end
```

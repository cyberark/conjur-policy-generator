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

      class Kubernetes
        <<Kubernetes Template Generator>>
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

def render_annotations hash
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

def policy name, *children, owner: nil, **annotations
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
  POLICY
  result += indent("owner: #{owner}")+"\n" if not owner.nil?
  result += indent(render_annotations(annotations))+"\n" if not annotations.empty?
  result += indent renderBody(children) if not children.empty?
  result.chomp
end

def user name
  "!user #{name}"
end

def group name
  "!group #{name}"
end

def host name=nil, **annotations
  return "!host #{name}" if annotations.empty?
  result = '!host'
  result += "\n" + indent('id: ') + name unless name.nil?
  result += "\n" + indent(render_annotations annotations) unless annotations.empty?
end

def webservice name=nil, **annotations
  return "!webservice#{' ' + name unless name.nil?}" if annotations.empty?
  result = '!webservice'
  result += "\n" + indent('id: ') + name unless name.nil?
  result += "\n" + indent(render_annotations annotations) unless annotations.empty?
end

def layer name=nil, **annotations
  return "!layer#{' ' + name unless name.nil?}" if annotations.empty?
  result = '!layer'
  result += "\n" + indent('id: ') + name unless name.nil?
  result += "\n" + indent(render_annotations annotations) unless annotations.empty?
end

def host_factory layer, name=nil
  result = "!host-factory"
  result += "\n" + indent('id: ') + name unless name.nil?
  result += "\n" + indent("layer: #{layer}")
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
    #{indent render_annotations annotations}
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

This is a classic pattern for controlling sensitive secrets: for each group of
secrets under control, we create a group that can only `read` and `update` those
secrets, then we create another group which can also `update` them.

```ruby
require_relative './constants'
include Conjur::PolicyGenerator

def initialize application_name = 'example',
               secret_groups = 2,
               secrets_per_group = 2,
               include_hostfactory = false
  @application_name = application_name
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
      policy('hosts', layer, host_factory(layer),
             description: 'Layer & Host Factory for machines that can read secrets'),
      groups.map { |group|
        grant(group("#{group}/secrets-users"),
              layer('hosts'))
      }
    ].flatten
  end

  yaml(
    policy(@application_name,
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

###### Kubernetes Template Generator

This template is based on the one created for the Conjur Kubernetes demo:
https://github.com/conjurdemos/kubernetes-conjur-demo/tree/master/policy/templates

```ruby
require_relative './constants'
include Conjur::PolicyGenerator

def initialize app_name='myapp',
               app_namespace='myorg',
               authenticator_id='authenticator'
  @app_name = app_name
  @app_namespace = app_namespace
  @authenticator_id = authenticator_id
end

def toMAML
  yaml(
    comment('Groups for separation of duties'),
    group('cluster-admin'),
    group('devops'),
    group('secrets-admin'),
    blank_line,
    policy('secrets',
           variable('db-password'),
           permit(layer("/#{@app_name}"),
                  ['read', 'execute'],
                  variable('db-password')),
           owner: group('secrets-admin'),
           description: 'grants secrets access to application layers'
          ),
    blank_line,
    policy(@app_name,
           layer,
           blank_line,
           comment(<<~COMMENT
             Add authn-k8s identities to application layer so its roles inherit
             app's permissions
           COMMENT
                  ),
           grant(layer,
                 layer("/conjur-authn-k8s/#{@authenticator_id}/apps")),
           owner: group('devops'),
           description: <<~DESCRIPTION
             |
               This policy connects authn identities to an application identity.
               It defines a layer named for an application that contains the
               whitelisted identities that can authenticate to the authn-k8s
               endpoint. Any permissions granted to the application layer will
               be inherited by the whitelisted authn identities, thereby
               granting access to the authenticated identity.)
           DESCRIPTION
          ),
    blank_line,
    comment('This policy defines an authn-k8s endpoint, CA creds,'),
    comment('and a layer for whitelisted identities permitted to authenticate to it'),
    blank_line,
    policy("conjur/authn-k8s/#{@authenticator_id}",
           webservice(description: 'authn service for the cluster'),
           blank_line,
           policy('ca',
                  variable('cert',
                           description: 'CA cert for Kubernetes Pods'),
                  variable('key',
                           description: 'CA key for Kubernetes Pods')),
           blank_line,
           comment('permit layer of authn ids for the authn service'),
           permit(layer("/conjur/authn-k8s/#{@authenticator_id}/apps"),
                  ['read', 'authenticate'],
                  webservice),
           policy('apps',
                  layer(description: 'Identities in this layer are permitted to use authn-k8s'),
                  taggedList('hosts',
                             host("#{@app_namespace}/*/*",
                                  :'kubernetes/authentication-container-name' => 'authenticator',
                                  openshift: 'true'),
                             host("#{@app_namespace}/service-account/#{@app_name}-api-sidecar",
                                  :'kubernetes/authentication-container-name' => 'authenticator',
                                  kubernetes: 'true'),
                             host("#{@app_namespace}/service-account/#{@app_name}-api-init",
                                  :'kubernetes/authentication-container-name' => 'authenticator',
                                  kubernetes: 'true')),
                  grant(layer,
                       '*hosts'),
                  owner: group('devops'),
                  description: 'Identities permitted to use authn-k8s'
                 ),
           owner: group('cluster-admin'),
           description: 'Namespace definitions for the Conjur cluster'
          ),
  )
end
```

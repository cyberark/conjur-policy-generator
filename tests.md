# Policy Generator Tests

To run these tests:
```sh-session
$ bin/build
Knot writing file: ./spec/humans_spec.rb
[...]
Sending build context to Docker daemon  38.63MB
Step 1/9 : FROM ruby:2.4.2-alpine
[...]
Successfully built 264c502fc630
Successfully tagged conjur-policy-generator:latest
$ bin/test
/usr/local/bin/ruby -I/usr/local/bundle/gems/rspec-support-3.7.1/lib:/usr/local/bundle/gems/rspec-core-3.7.1/lib /usr/local/bundle/gems/rspec-core-3.7.1/exe/rspec --pattern spec/\*\*\{,/\*/\*\*\}/\*_spec.rb
.......

Finished in 0.00835 seconds (files took 0.11772 seconds to load)
7 examples, 0 failures
```

### Design & Purpose of Tests

These tests compare a policy from a given generator to a pre-computed "correct"
policy. This ensures that refactoring and changes in the helpers or program
structure introduced during development of new policy generators doesn't break
or change the formatting of existing policy generators.

A future goal for testing would be to actually load these into a Conjur server,
verifying that the generated policies are syntactically correct and load
cleanly.

#### Literate testing note

Policy text (like `<<Policy 211>>`) will be interpolated by `knot` from the
subheading with the same name (eg `###### Policy 211`) when you tangle.

Subheadings with filenames like `###### file:spec/humans_spec.rb` will have
their following code block converted into the named file.

You can view the final spec files like so:
```sh-session
$ bundle exec rake tangle
mkdir -p src/ruby
Knot writing file: ./spec/humans_spec.rb
Knot writing file: ./spec/policies.rb
Knot writing file: ./spec/secret_control_template_spec.rb
Knot writing file: ./spec/secrets_spec.rb
Knot writing file: src/ruby/constants.rb
Knot writing file: src/ruby/generator.rb
$ ls spec
humans_spec.rb			secrets_spec.rb
policies.rb			spec_helper.rb
secret_control_template_spec.rb
```

## Test Implementation

###### file:spec/humans_spec.rb
```ruby
require_relative '../src/ruby/generator'
require_relative './policies'

include RSpec
include Conjur::PolicyGenerator

describe Humans do
  it 'generates a default policy' do
    expect(described_class.new().toMAML).to eq(policy211)
  end

  it 'generates a policy for 4 users, 2 groups, 4 users per group with inline lists' do
    expect(described_class.new(4,2,4).toMAML).to eq(policy424)
  end

  it 'generates a policy for 5 users, 2 groups, 5 users per group with vertical lists' do
    expect(described_class.new(5,2,5).toMAML).to eq(policy525)
  end
end
```

###### file:spec/secrets_spec.rb
```ruby
require_relative '../src/ruby/generator'
require_relative './policies'

include RSpec
include Conjur::PolicyGenerator

describe Secrets do
  it 'generates a default policy' do
    expect(described_class.new().toMAML).to eq(policySecrets10)
  end

  it 'generates a policy for 2 secrets with 5 annotations each' do
    expect(described_class.new(2,5).toMAML).to eq(policySecrets25)
  end
end
```

###### file:spec/secret_control_template_spec.rb
```ruby
require_relative '../src/ruby/generator'
require_relative './policies'

include RSpec
include Conjur::PolicyGenerator::Template

describe SecretControl do
  it 'generates a default policy' do
    expect(described_class.new().toMAML).to eq(templateSecretControlDefault)
  end

  it 'generates a companion policy with a layer & host factory' do
    expect(described_class.new('example-with-host-factory', 2, 3,
                               include_hostfactory: true).toMAML
          ).to eq(templateSecretControlWithHF)
  end
end
```

###### file:spec/authn_k8s_template_spec.rb
```ruby
require_relative '../src/ruby/generator'
require_relative './policies'

include RSpec
include Conjur::PolicyGenerator::Template

describe Kubernetes do
  it 'generates a default policy' do
    expect(described_class.new().toMAML).to eq(templateK8sDefault)
  end
end
```

## Target Policies for Load Testing

###### file:spec/policies.rb
```ruby
def policy211
  <<~EOF
    <<Policy 211>>
  EOF
end

def policy424
  <<~EOF
    <<Policy 424>>
  EOF
end

def policy525
  <<~EOF
    <<Policy 525>>
  EOF
end

def policySecrets10
  <<~EOF
    <<Policy: 1 variable with no annotations>>
  EOF
end

def policySecrets25
  <<~EOF
    <<Policy: 2 variables with 5 annotations each>>
  EOF
end

def templateSecretControlDefault
  <<~EOF
    <<Policy: default template policy for secret control>>
  EOF
end

def templateSecretControlWithHF
  <<~EOF
    <<Policy: template policy for secret control with host factory policy>>
  EOF
end

def templateK8sDefault
  <<~EOF
    <<Policy: default template policy for authn-k8s>>
  EOF
end
```

### Humans

###### Policy 211
```yaml
---
- !user alice
- !user bob
- !group aardvark
- !grant
  role: !group aardvark
  member: !user alice
```

###### Policy 424
```yaml
---
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
```

###### Policy 525
```yaml
---
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
```

### Secrets

###### Policy: 1 variable with no annotations
```
---
- !variable hydrogen
```

###### Policy: 2 variables with 5 annotations each

```
---
- !variable
  id: hydrogen
  annotations:
    density: value
    color: value
    conductivity: value
    malleability: value
    luster: value
- !variable
  id: lithium
  annotations:
    density: value
    color: value
    conductivity: value
    malleability: value
    luster: value
```

## Target Policies for Template Generators

### Secret Control

###### Policy: default template policy for secret control

```
---
- !policy
  id: example
  body:
    - !policy
      id: alfa
      body:
        # Secret Declarations
        - &secrets
          - !variable hydrogen
          - !variable lithium
        
        # User & Manager Groups
        - !group secrets-users
        - !group secrets-managers
        - !permit
          role: !group secrets-users
          privileges: [ read, execute ]
          resources: *secrets
        - !permit
          role: !group secrets-managers
          privileges: [ read, execute, update ]
          resources: *secrets
    - !policy
      id: bravo
      body:
        # Secret Declarations
        - &secrets
          - !variable sodium
          - !variable potassium
        
        # User & Manager Groups
        - !group secrets-users
        - !group secrets-managers
        - !permit
          role: !group secrets-users
          privileges: [ read, execute ]
          resources: *secrets
        - !permit
          role: !group secrets-managers
          privileges: [ read, execute, update ]
          resources: *secrets
```

###### Policy: template policy for secret control with host factory policy

```
---
- !policy
  id: example-with-host-factory
  body:
    - !policy
      id: alfa
      body:
        # Secret Declarations
        - &secrets
          - !variable hydrogen
          - !variable lithium
          - !variable sodium
        
        # User & Manager Groups
        - !group secrets-users
        - !group secrets-managers
        - !permit
          role: !group secrets-users
          privileges: [ read, execute ]
          resources: *secrets
        - !permit
          role: !group secrets-managers
          privileges: [ read, execute, update ]
          resources: *secrets
    - !policy
      id: bravo
      body:
        # Secret Declarations
        - &secrets
          - !variable potassium
          - !variable rubidium
          - !variable caesium
        
        # User & Manager Groups
        - !group secrets-users
        - !group secrets-managers
        - !permit
          role: !group secrets-users
          privileges: [ read, execute ]
          resources: *secrets
        - !permit
          role: !group secrets-managers
          privileges: [ read, execute, update ]
          resources: *secrets
    
    # === Layer for Automated Secret Access ===
    - !policy
      id: hosts
      annotations:
        description: Layer & Host Factory for machines that can read secrets
      body:
        - !layer
        - !host-factory
    - !grant
      role: !group alfa/secrets-users
      member: !layer hosts
    - !grant
      role: !group bravo/secrets-users
      member: !layer hosts
```

###### Policy: default template policy for authn-k8s

```
---
# Groups for separation of duties
- !group cluster-admin
- !group devops
- !group secrets-admin

- !policy
  id: secrets
  owner: !group secrets-admin
  annotations:
    description: grants secrets access to application layers
  body:
    - !variable db-password
    - !permit
      role: !layer /myapp
      privileges: [ read, execute ]
      resource: !variable db-password

- !policy
  id: myapp
  owner: !group devops
  annotations:
    description: |
      This policy connects authn identities to an application identity.
      It defines a layer named for an application that contains the
      whitelisted identities that can authenticate to the authn-k8s
      endpoint. Any permissions granted to the application layer will
      be inherited by the whitelisted authn identities, thereby
      granting access to the authenticated identity.)
  body:
    - !layer
    
    # Add authn-k8s identities to application layer so its roles inherit
    app's permissions
    
    - !grant
      role: !layer
      member: !layer /conjur-authn-k8s/authenticator/apps

# This policy defines an authn-k8s endpoint, CA creds,
# and a layer for whitelisted identities permitted to authenticate to it

- !policy
  id: conjur/authn-k8s/authenticator
  owner: !group cluster-admin
  annotations:
    description: Namespace definitions for the Conjur cluster
  body:
    - !webservice
      annotations:
        description: authn service for the cluster
    
    - !policy
      id: ca
      body:
        - !variable
          id: cert
          annotations:
            description: CA cert for Kubernetes Pods
        - !variable
          id: key
          annotations:
            description: CA key for Kubernetes Pods
    
    # permit layer of authn ids for the authn service
    - !permit
      role: !layer /conjur/authn-k8s/authenticator/apps
      privileges: [ read, authenticate ]
      resource: !webservice
    - !policy
      id: apps
      owner: !group devops
      annotations:
        description: Identities permitted to use authn-k8s
      body:
        - !layer
          annotations:
            description: Identities in this layer are permitted to use authn-k8s
        - &hosts
          - !host
            id: myorg/*/*
            annotations:
              kubernetes/authentication-container-name: authenticator
              openshift: true
          - !host
            id: myorg/service-account/myapp-api-sidecar
            annotations:
              kubernetes/authentication-container-name: authenticator
              kubernetes: true
          - !host
            id: myorg/service-account/myapp-api-init
            annotations:
              kubernetes/authentication-container-name: authenticator
              kubernetes: true
        - !grant
          role: !layer
          member: *hosts
```

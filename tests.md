# Policy Generator Tests

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

describe Secrets do
  it 'generates a default policy' do
    expect(described_class.new().toMAML).to eq(policySecrets10)
  end

  it 'generates a policy for 2 secrets with 5 annotations each' do
    expect(described_class.new(2,5).toMAML).to eq(policySecrets25)
  end
end
```

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
```

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

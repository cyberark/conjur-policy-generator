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

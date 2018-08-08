# Constants

These are used for user and group names in generated policies.

###### file:ruby/constants.rb

```ruby
module Conjur::PolicyGenerator
  <<Human Names>>

  <<Animal Names>>

  <<Variable Names>>

  <<Annotation Names>>
end
```

###### Human Names
Source: https://en.wikipedia.org/wiki/Alice_and_Bob

```ruby
HUMAN_NAMES = [
  'alice',
  'bob',
  'carol',
  'dan',
  'erin',
  'frank',
  'grace',
  'heidi',
  'judy',
  'mallory',
  'olivia',
  'peggy',
  'sibyl',
  'trent',
  'victor',
  'wendy'
]
```

###### Animal Names
Source: http://www.naturalhistoryonthenet.com/Mammals/a-z.htm

```ruby
ANIMAL_NAMES = [
  'aardvark',
  'bobcat',
  'caribou',
  'dugong',
  'elephant',
  'fossa',
  'giraffe',
  'hedgehog',
  'impala',
  'jaguar',
  'koala',
  'lynx',
  'moose',
  'narwhal',
  'otter',
  'possum',
  'raccoon',
  'squirrel',
  'tapir',
  'walrus',
  'zebra'
]
```

###### Variable Names
```ruby
VARIABLE_NAMES = [
  'hydrogen',
  'lithium',
  'sodium',
  'potassium',
  'rubidium',
  'caesium',
  'francium'
]
```

###### Annotation Names

```ruby
ANNOTATION_NAMES = [
  'density',
  'color',
  'conductivity',
  'malleability',
  'luster',
  'mass',
  'volume',
  'length'
]
```

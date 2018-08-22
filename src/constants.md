# Constants

These are used for user and group names in generated policies.

###### file:ruby/constants.rb

```ruby
module Conjur
  module PolicyGenerator
    HUMAN_NAMES = [
      '<<Human Names>>',
    ]

    ANIMAL_NAMES = [
      '<<Animal Names>>',
    ]

    VARIABLE_NAMES = [
      '<<Variable Names>>',
    ]

    ANNOTATION_NAMES = [
      '<<Annotation Names>>',
    ]

    NATO_ALPHABET = [
      '<<NATO Alphabet>>',
    ]
  end
end
```

###### Human Names
Source: https://en.wikipedia.org/wiki/Alice_and_Bob

```
alice
bob
carol
dan
erin
frank
grace
heidi
judy
mallory
olivia
peggy
sibyl
trent
victor
wendy
```

###### Animal Names
Source: http://www.naturalhistoryonthenet.com/Mammals/a-z.htm

```
aardvark
bobcat
caribou
dugong
elephant
fossa
giraffe
hedgehog
impala
jaguar
koala
lynx
moose
narwhal
otter
possum
raccoon
squirrel
tapir
walrus
zebra
```

###### Variable Names
```
hydrogen
lithium
sodium
potassium
rubidium
caesium
francium
```

###### Annotation Names

```
density
color
conductivity
malleability
luster
mass
volume
length
```

###### NATO Alphabet
As per https://en.wikipedia.org/wiki/NATO_phonetic_alphabet

```
alfa
bravo
charlie
delta
echo
foxtrot
golf
hotel
india
juliett
kilo
lima
mike
november
oscar
papa
quebec
romeo
sierra
tango
uniform
victor
whiskey
x-ray
yankee
zulu
```

# Description

It defines `Enumerable#each_with_hash`, which is a simple wrapper for `Enumerable#each_with_object({})`.

It also includes the alias `Enumerator#with_hash(&)`.

# Requiring

```ruby
# As a refinement
require 'trinkets/enumerable/each_with_hash' # implicit
# or
require 'trinkets/refine/enumerable/each_with_hash' # explicit 

# As include
require 'trinkets/include/enumerable/each_with_hash'

# As monkey-patch
require 'trinkets/patch/enumerable/each_with_hash'
```

# Examples

These examples are all equivalent.

```ruby
[2, 3, 4, 5].each_with_hash { |value, hash| hash[value] = value * value }
# => {2=>4, 3=>9, 4=>16, 5=>25}

[2, 3, 4, 5].each_with_hash
# => #<Enumerator: [2, 3, 4, 5]:each_with_object({})>
```

```ruby
[2, 3, 4, 5].each
  .with_hash { |value, hash| hash[value] = value * value }

# => {2=>4, 3=>9, 4=>16, 5=>25}
```

```ruby
[2, 3, 4, 5].each
  .with_hash
  .each { |value, hash| hash[value] = value * value }

# => {2=>4, 3=>9, 4=>16, 5=>25}
```

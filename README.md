# Trinkets

It's the bootleg facets

## Installation

```
gem install trinkets
```

## Usage

There are 3 ways to use trinkets
### Loading
#### Refinement

```ruby
require 'trinkets/class/init/refine'

using ::Trinkets::Class::Init
```

#### Extend

```ruby
require 'trinkets/class/init/extend'

class Test
  extend ::Trinkets::Class::Init
end
```

#### Mokey Patching

```ruby
require 'trinkets/class/init'
```

### Available modules

|Trinket|
|---|
|[class/init](doc/class/init.md)|

## Development

[//]: # (TODO)

## Contributing

[//]: # (TODO)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

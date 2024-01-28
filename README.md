# Trinkets

It's the bootleg [facets](https://github.com/rubyworks/facets?tab=readme-ov-file#ruby-facets).

## Installation

```
gem install trinkets
```

## Usage

There are 3 ways to load trinkets:
* As refinements;
* As explicit `include` or `extend`;
* As implicit `include` or `extend`, a.k.a. monkey-patching.

### Refinement

```ruby
require 'trinkets/refine/class/init'

using ::Trinkets::Class::Init
```

### Extend

```ruby
require 'trinkets/extend/class/init'

class Test
  extend ::Trinkets::Class::Init
end
```

### Mokey Patching

```ruby
require 'trinkets/patch/class/init'
```

## Available modules

|Trinket|
|---|
|[class/init](doc/class/init.md)|

[//]: # (TODO: Development)
[//]: # (TODO: Contributing)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Trinkets

It's the bootleg [facets](https://github.com/rubyworks/facets?tab=readme-ov-file#ruby-facets).

## Installation

```
gem install trinkets
```

## Usage

The trinkets are loaded with the following structure:
```ruby
require 'trinkets/{how-to-patch}/{class}/{method}'
```

There are 3 ways to load trinkets, which are represented by the `{how-to-patch}` portion in the requires:
* `refine` : As refinements;
* `extend`/`include` : As explicit `include` or `extend`;
* `patch` : As implicit `include` or `extend`, a.k.a. monkey-patching.

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

## Versioning

Versions follow semantic versioning: `major.minor.patch`
* `major`: breaking changes.
* `minor`: improvements and new features that are backwards compatible.
* `patch`: backwards compatible fixes to existing features.

[//]: # (TODO: Development)

## Contributing

Steps to include when developing the feature/fix:
* Add or change the appropriate RSpec tests.
* Document the feature.
  * Might not apply to fixes if the feature didn't change.
* Bump the version.
* Update the Changelog.

[//]: # (TODO: Contributing)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

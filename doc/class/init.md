# Description

It allows generating simple `#initialize` methods.

To use it, define a class and call `::init` like you would call `::attr` methods:
* pass the name of the arguments as symbols
* pass options at the end:
  * `attr` : what getters and/or setters to define
    * can be `:accessor`, `:reader`, `:writer` or `:none` 
    * defaults to `:accessor`
  * `kw` : if arguments are to be set as keyword arguments
    * when `false`, it's a mandatory positional argument
    * when `true`, it becomes a mandatory keyword argument, like `(a:)`
    * when it's a hash, like `{ default: <VALUE> }`, it's an optional keyword argument
    * an empty hash `{}` is equivalent to `{ default: nil }`
    * defaults to `false`
  * `super` : if the argument should be passed to `super()`
    * the super class can have a `initialize` or call `init`
    * default: `false`

The same options can be used per individual argument.

# Requiring

```ruby
# As a refinement
require 'trinkets/class/init' # implicit
# or
require 'trinkets/refine/class/init' # explicit 

# As extend
require 'trinkets/extend/class/init'

# As monkey-patch
require 'trinkets/patch/class/init'
```

# Examples

## Simple Initialize
```ruby
class Test
  init :a, :b
end

# would be the same as
class Test
  attr_accessor :a, :b
  def initialize(a, b)
    super()
    @a = a unless instance_variable_defined?(:@a)
    @b = b unless instance_variable_defined?(:@b)
  end
end

test = Test.new(1, 2)

test.a
# 1

test.b
# 2

test.a = 3
# 3
```

## Read only access to instance variables
```ruby
class TestAttr
  init :a, :b, attr: :reader
end

# would be the same as
class TestAttr
  attr_reader :a, :b
  def initialize(a, b)
    super()
    @a = a unless instance_variable_defined?(:@a)
    @b = b unless instance_variable_defined?(:@b)
  end
end

test = TestAttr.new(1, 2)

test.a
# 1

test.b
# 2

test.a = 3
# => raises NoMethodError
```

## Initialize uses keyword arguments
```ruby
class TestKW
  init :a, :b, kw: :true
end

# would be the same as
class TestKW
  attr_accessor :a, :b
  def initialize(a:, b:)
    super()
    @a = a unless instance_variable_defined?(:@a)
    @b = b unless instance_variable_defined?(:@b)
  end
end

test = TestKW.new(a: 1, b: 2)

test.a
# 1

test.b
# 2
```

## Individual attribute options
```ruby
class TestAttrOptions
  init [:a, kw: true, attr: :reader],
       :b,
       [:c, kw: true],
       [:d, attr: :none]
end

# would be the same as
class TestAttrOptions
  attr_reader :a
  attr_accessor :b, :c
  def initialize(b, d, a:, c:)
    super()
    @a = a unless instance_variable_defined?(:@a)
    @b = b unless instance_variable_defined?(:@b)
    @c = c unless instance_variable_defined?(:@c)
    @d = d unless instance_variable_defined?(:@d)
  end
end

test = TestAttrOptions.new(2, 4, a: 1, c: 3)

test.a
# 1

test.b
# 2

test.c
# 3

test.d
# => raises NoMethodError

test.a = 5
# => raises NoMethodError
```

## Default values for keyword arguments
```ruby
class TestDefaultKw
  init [:a, kw: true],
       :b,
       kw: {default: 3}
end

# would be the same as
class TestDefaultKw
  attr_accessor :a, :b
  def initialize(a:, b: 3)
    super()
    @a = a unless instance_variable_defined?(:@a)
    @b = b unless instance_variable_defined?(:@b)
  end
end

test = TestDefaultKw.new(a: 2)

test.a
# 2

test.b
# 3
``` 

## Super
```ruby
class TestParent
  init :a # also works with a plain initialize()
end

class TestChild
  init [:a, super: true], :b
end

# would be the same as
class TestChild
  attr_accessor :a, :b
  def initialize(a, b)
    super(a)
    @a = a unless instance_variable_defined?(:@a)
    @b = b unless instance_variable_defined?(:@b)
  end
end
```

## Mixed together
```ruby
class TestMixed
  init [:a, attr: :reader],
       :b,
       kw: true
end

# would be the same as
class TestMixed
  attr_reader :a
  attr_accessor :b
  def initialize(a:, b:)
    super()
    @a = a unless instance_variable_defined?(:@a)
    @b = b unless instance_variable_defined?(:@b)
  end
end

test = TestMixed.new(1, 2)

test.a
# 1

test.b
# 2

test.b = 3
# 3

test.a = 4
# => raises NoMethodError
```

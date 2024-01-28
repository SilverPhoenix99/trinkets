# Description

It allows generating simple `#initialize` methods.

To use it define a class and call `::init` like you would call `::attr` methods:
* pass the name of the arguments as symbols
* pass options at the end:
  * `attr` : what getters and/or setters to define
    * can be `:accessor`, `:reader` or `:writer` 
    * defaults to `:accessor`
  * `kw` : if arguments are to be set as keyword arguments
    * defaults to `false`

The same options can be used per individual argument

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
    @a = a
    @b = b
  end
end

test = Test.new(1, 2)
test.a
# 1

test.b
# 2

test.a = 3
test.a
# 3
```

## Read only access to instance variables
```ruby
class TestAttr
  init :a, :b, attr: :reader
end

# would be the same as
class Test
  attr_reader :a, :b
  def initialize(a, b)
    @a = a
    @b = b
  end
end

test = Test.new(1, 2)
test.a
# 1

test.b
# 2

test.a = 3
# > raises ArgumentError
```

## Initialize uses keyword arguments
```ruby
class TestKW
  init :a, :b, kw: :true
end

# would be the same as
class Test
  attr_accessor :a, :b
  def initialize(a:, b:)
    @a = a
    @b = b
  end
end

test = Test.new(a: 1, b: 2)
test.a
# 1

test.b
# 2
```

## Individual argument options
```ruby
class TestIndividualArgsOptions
  init [:a, kw: true, attr: :reader], :b, [:c, kw: true]
end

# would be the same as
class Test
  attr_reader :a
  attr_accessor :b, :c
  def initialize(b, a:, c:)
    @a = a
    @b = b
  end
end

test = Test.new(2, a: 1, c: 3)
test.a
# 1

test.b
# 2

test.c
# 3

test.a = 4
# > raises ArgumentError
```
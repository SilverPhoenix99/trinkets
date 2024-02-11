# frozen_string_literal: true

require_relative '../../../../lib/explicit/trinkets/extend/class/init'

RSpec.describe ::Trinkets::Class::Init do

  describe 'extend' do

    subject do
      Class.new do
        extend ::Trinkets::Class::Init
      end
    end

    it 'has no visibility of ATTR constant' do
      expect { subject::ATTR }.to raise_error(NameError)
    end

    it 'has no visibility of `sanitize_attrs` method' do
      expect(subject).to_not respond_to(:sanitize_attrs)
    end

    it 'has no visibility of `define_initialize` method' do
      expect(subject).to_not respond_to(:define_initialize)
    end

    it 'defines self.init' do
      expect(subject).to respond_to(:init)
    end

    it 'attr_reader to be defined' do
      subject.init(:a, :@b)
      instance = subject.new(1, 2)
      expect(instance.a).to eq(1)
      expect(instance.b).to eq(2)

      expect { instance.c }.to raise_error(NoMethodError)
    end

    it 'attr_writer to be defined' do
      subject.init(:c)
      instance = subject.new(1)
      instance.c = 2
      expect(instance.c).to eq(2)
    end

    it 'raises an ArgumentError if no argument is passed' do
      expect { subject.init }.to raise_error(ArgumentError, 'At least 1 attribute is required.')
    end

    it 'raises an ArgumentError if wrong number of arguments are passed' do
      subject.init(:c)
      expect { subject.new(1, 2) }.to raise_error(ArgumentError, "wrong number of arguments (given 2, expected 1)")
    end

    it 'raises an ArgumentError if attr is invalid' do
      expect { subject.init(:a, attr: :random) }.to raise_error(ArgumentError,
        'wrong `attr` type (given :random, expected :accessor (default), :reader, :writer or :none)')
    end

    it 'raises an ArgumentError if attr from an argument is invalid' do
      expect { subject.init(:b, [:a, attr: :random]) }.to raise_error(ArgumentError,
        "wrong `attr` type for `:a` (given :random, expected :accessor (default), :reader, :writer or :none)")
    end
  end

  describe 'repeated parameters' do
    it 'does not accept repeated arguments' do
      expect {
        Class.new do
          extend ::Trinkets::Class::Init
          init :a, :@a, :b, [:b], :c, :d, :d, :e, [:e, kw: true]
        end
      }.to raise_error(ArgumentError, "duplicated argument names: a, b, d, e")
    end
  end

  describe 'override default attr: :reader' do

    let(:klass) do
      Class.new do
        extend ::Trinkets::Class::Init
        init :a, attr: :reader
      end
    end

    subject { klass.new(1) }

    it 'only defines read-only attributes' do
      expect(subject).to respond_to(:a)
      expect(subject).to_not respond_to(:a=)
    end
  end

  describe 'override default attr: :writer' do

    let(:klass) do
      Class.new do
        extend ::Trinkets::Class::Init
        init :a, attr: :writer
      end
    end

    subject { klass.new(1) }

    it 'only defines write-only attributes' do
      expect(subject).to_not respond_to(:a)
      expect(subject).to respond_to(:a=)
    end

  end

  describe 'override default attr: :none' do

    let(:klass) do
      Class.new do
        extend ::Trinkets::Class::Init
        init :a, attr: :none
      end
    end

    subject { klass.new(1) }

    it "doesn't define any attribute" do
      expect(subject).to_not respond_to(:a, :a=)
    end

  end

  describe 'override kw: true' do

    subject do
      Class.new do
        extend ::Trinkets::Class::Init
        init :a, :b, kw: true
      end
    end

    it 'defines keyword arguments' do
      instance = subject.new(a: 1, b: 2)

      expect(instance.a).to eq(1)
      expect(instance.b).to eq(2)
    end

    it "raises an ArgumentError if it isn't keyword arguments" do
      expect { subject.new(42, 43) }.to raise_error(ArgumentError, 'wrong number of arguments (given 2, expected 0)')
    end

    it 'raises an ArgumentError if keywords are not present' do
      expect { subject.new(a: 1) }.to raise_error(ArgumentError, 'missing keywords: :b')
      expect { subject.new(a: 1, c: 3) }.to raise_error(ArgumentError, 'missing keywords: :b')
    end

    it 'raises an ArgumentError if keywords are unknown' do
      expect { subject.new(a: 1, b: 2, c: 3) }.to raise_error(ArgumentError, 'unknown keywords: :c')
    end

  end

  describe 'attributes override default options' do

    subject do
      Class.new do
        extend ::Trinkets::Class::Init
        init [:a, attr: :reader],
             :b,
             [:c, kw: true]
      end
    end

    it 'only defines read-only @a attribute' do
      instance = subject.new(1, 2, c: 3)

      expect(instance).to respond_to(:a, :b, :c, :b=, :c=)
      expect(instance).to_not respond_to(:a=)
    end

  end

  describe 'kw arguments can have default value' do
    subject do
      Class.new do
        extend ::Trinkets::Class::Init
        init [:a, kw: {default: 3}],
             :b,
             [:c, kw: true],
             [:d, kw: {}]
      end
    end

    it 'initializes kw argument with a default' do
      instance = subject.new(4, c: 42)
      expect(instance).to have_attributes(a: 3, b: 4, c: 42, d: nil)
      expect(instance).to respond_to(:a=, :b=, :c=, :d=)
      expect(instance).to be_instance_variable_defined(:@d)
      expect(instance.d).to eq(nil)
    end
  end

  describe 'default kw arguments can have default value' do
    subject do
      Class.new do
        extend ::Trinkets::Class::Init
        init [:a, kw: {default: 3}],
             :b,
             [:c, kw: true],
             [:d, kw: {}],
             kw: {default: 'value'}
      end
    end

    it 'initializes kw argument with a default' do
      instance = subject.new(c: 42)
      expect(instance).to have_attributes(a: 3, b: 'value', c: 42, d: nil)
      expect(instance).to respond_to(:a=, :b=, :c=, :d=)
      expect(instance).to be_instance_variable_defined(:@d)
    end
  end
end

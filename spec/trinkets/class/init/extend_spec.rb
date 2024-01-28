# frozen_string_literal: true

require_relative '../../../../lib/trinkets/class/init/extend'

RSpec.describe ::Trinkets::Class::Init do

  describe 'extend' do

    subject do
      Class.new do
        extend ::Trinkets::Class::Init
      end
    end

    it 'defines self.init' do
      expect(subject).to respond_to(:init)
    end

    it 'attr_reader to be defined' do
      subject.init(:a, :@b)
      instance = subject.new(1, 2)
      expect(instance.a).to eq(1)
      expect(instance.b).to eq(2)

      expect { instance.c }.to raise_error NoMethodError
    end

    it 'attr_writer to be defined' do
      subject.init(:c)
      instance = subject.new(1)
      instance.c = 2
      expect(instance.c).to eq(2)
    end
  end

  describe 'attr: :reader' do

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
end

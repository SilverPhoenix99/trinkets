# frozen_string_literal: true

require_relative '../../../../lib/explicit/trinkets/refine/enumerable/each_with_hash'

using ::Trinkets::Enumerable::WithHash

RSpec.describe ::Trinkets::Enumerable::WithHash do

  let(:array) { [[:a, 1],  [:b, 2]] }
  let(:expected) { { a: 1, b: 2 } }
  let(:enumerable_class) {
    Class.new do
      include Enumerable

      def each
        [].each
      end
    end
  }

  describe 'enumerable' do
    it 'can be called from Enumerable' do
      actual = array.each_with_hash do |(k, v), h|
        h[k] = v
      end

      expect(actual).to eq(expected)
    end

    it 'returns an Enumerator if block is not given' do
      expect(array.each_with_hash).to be_a(Enumerator)
    end

    it 'returns an Enumerator when each is called on it' do
      expect(array.each_with_hash.each).to be_a(Enumerator)
    end

    it 'can be called from a class including Enumerable' do
      instance = enumerable_class.new
      expect(instance.respond_to?(:each_with_hash)).to be(true)
    end
  end

  describe 'enumerator' do
    it 'can be called from Enumerators' do
      actual = array.each.with_hash do  |(k, v), h|
        h[k] = v
      end

      expect(actual).to eq(expected)
    end

    it 'returns an Enumerator if block is not given' do
      expect(array.each.with_hash).to be_a(Enumerator)
    end

    it 'returns an Enumerator when each is called on it' do
      expect(array.each.with_hash.each).to be_a(Enumerator)
    end

    it 'can be called from an enumerator from a class including Enumerable' do
      instance = enumerable_class.new
      expect(instance.each.respond_to?(:with_hash)).to be(true)
    end
  end
end
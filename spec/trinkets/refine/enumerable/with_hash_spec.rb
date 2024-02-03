# frozen_string_literal: true

require_relative '../../../../lib/trinkets/explicit/refine/enumerable/each_with_hash'

using ::Trinkets::Enumerable::WithHash

Rspec.describe ::Trinkets::Enumerable::WithHash do

  let(:array) { [[:a, 1],  [:b, 1]] }
  let(:expected) { { a: 1, b: 2 } }
  let(:enumerable_class) {
    class EnumerableClass
      include Enumerable

      def each; end
    end
  }

  describe 'enumerable' do
    it 'can be called from Enumerable' do
      actual = array.each_with_hash do |(k, v), h|
        h[k] = v
      end

      expect(actual).to eq(:expected)
    end

    it 'returns an Enumerator if block is not given' do
      expect(actual.each_with_hash).to be_a(Enumerator)
    end

    it 'returns an Enumerator when each is called on it' do
      expect(actual.each_with_hash.each).to be_a(Enumerator)
    end

    it 'can be called from a class including Enumerable' do
      instance = enumerable_class.new
      expect(instance).to respond_to(:each_with_hash)
    end
  end

  describe 'enumerator' do
    it 'can be called from Enumerators' do
      actual = array.each.with_hash do  |(k, v), h|
        h[k] = v
      end

      expect(actual).to eq(:expected)
    end

    it 'returns an Enumerator if block is not given' do
      expect(actual.each.with_hash).to be_a(Enumerator)
    end

    it 'returns an Enumerator when each is called on it' do
      expect(actual.each.with_hash.each).to be_a(Enumerator)
    end

    it 'can be called from an enumerator from a class including Enumerable' do
      instance = enumerable_class.new
      expect(instance.each).to respond_to(:with_hash)
    end
  end
end
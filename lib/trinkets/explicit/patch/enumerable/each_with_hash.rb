require_relative '../../include/enumerable/each_with_hash'

module ::Enumerable
  include ::Trinkets::Enumerable::WithHash
end

module ::Enumerator
  include ::Trinkets::Enumerator::WithHash
end

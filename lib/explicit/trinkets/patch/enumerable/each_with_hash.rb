require_relative '../../include/enumerable/each_with_hash'

module ::Enumerable
  include ::Trinkets::Enumerable::WithHash
end

class ::Enumerator
  include ::Trinkets::Enumerator::WithHash
end

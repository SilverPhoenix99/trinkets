require_relative '../../include/enumerable/each_with_hash'

module Trinkets
  module Enumerable
    module WithHash
      refine ::Enumerable do
        import_methods ::Trinkets::Enumerable::WithHash
      end

      refine ::Enumerator do
        import_methods ::Trinkets::Enumerator::WithHash
      end
    end
  end
end

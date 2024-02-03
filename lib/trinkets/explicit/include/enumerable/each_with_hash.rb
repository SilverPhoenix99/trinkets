module Trinkets

  module Enumerable
    module WithHash
      def each_with_hash(&) = each_with_object({}, &)
    end
  end

  module Enumerator
    module WithHash
      def with_hash(&) = each_with_hash(&)
    end
  end
end

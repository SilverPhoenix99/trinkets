module Trinkets

  module Enumerable
    module WithHash
      def each_with_hash(&)
        return enum_for(:each_with_hash) unless block_given?
        each_with_object({}, &)
      end
    end
  end

  module Enumerator
    module WithHash
      alias_method :with_hash, :each_with_hash
    end
  end
end

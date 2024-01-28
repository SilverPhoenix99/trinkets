require_relative 'extend'

module Trinkets
  module Class
    module Init
      refine ::Class do
        import_methods ::Trinkets::Class::Init
      end
    end
  end
end

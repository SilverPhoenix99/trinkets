require_relative 'init/extend'

class ::Class
  include ::Trinkets::Class::Init
end

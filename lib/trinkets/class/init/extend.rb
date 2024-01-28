# frozen_string_literal: true

module Trinkets
  module Class
    module Init
      ATTR = %i[accessor reader writer].freeze

      def init(*attrs, attr: ATTR.first)
        raise ArgumentError, 'At least 1 attribute is required.' if attrs.empty?
        raise ArgumentError, '`attr` must be one of :accessor (default), :reader or :writer' unless ATTR.include?(attr)

        attr_method = method("attr_#{attr}")

        attrs = attrs.map { |name| name.to_s.sub(/^@/, '') }
        attr_method.call(*attrs)

        attrs = attrs.map { |name| :"@#{name}" }

        define_method :initialize do |*values|
          unless attrs.size == values.size
            raise ArgumentError, "wrong number of arguments (given #{values.size}, expected #{attrs.size})"
          end

          attrs.zip(values).each do |name, value|
            instance_variable_set name, value
          end

        end
      end
    end
  end
end

__END__

class X
  init :a, :@b

  init(
    [:a, read_only: true],
    :b,
    { kw: true, read_only: true } # defaults for all args
  )
end

X.new(1, 2)
X.new(a: 1, b: 2)

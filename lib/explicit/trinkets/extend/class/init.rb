# frozen_string_literal: true

module Trinkets
  module Class
    module Init
      ATTR = %i[accessor reader writer none].freeze

      def init(*attrs, attr: ATTR.first, kw: false)
        raise ArgumentError, 'At least 1 attribute is required.' if attrs.empty?
        raise ArgumentError, '`attr` must be one of :accessor (default), :reader, :writer or :none' unless ATTR.include?(attr)

        default_attr_options = { attr: attr, kw: kw }

        attrs = ::Trinkets::Class.send(:sanitize_attrs, attrs, default_attr_options)

        attr_methods = (ATTR - [:none])
          .each_with_object({}) do |name, h|
            h[name] = method("attr_#{name}")
          end

        # even though options like `kw` aren't used, they serve here to validate the `attrs` options
        attr_init = ->(name, attr: ATTR.first, kw: false) do
          unless ATTR.include?(attr)
            raise ArgumentError, "attr `#{name}`, option attr` must be one of :accessor (default), :reader, :writer or :none"
          end
          attr_methods[attr].call(name) unless attr == :none
        end

        attrs.each { |name, opts| attr_init.call(name, **opts) }

        # 2 hashes: { :name => bool }
        kw_attrs, attrs = attrs
          .map  { |name, opts| [name, opts[:kw]] }
          .partition { |_, kw_opt| kw_opt }
          .map(&:to_h)

        init_method = ::Trinkets::Class.send(:define_initialize, attrs, kw_attrs)
        define_method :initialize, init_method
      end
    end

    class << self
      private def sanitize_attrs(attrs, default_attr_options)
        # Normalize attrs into an array: [[:name, **options], ...]
        # @type [Array[Array[Symbol, Hash]]]
        attrs = attrs.map do |a|
          name, opts = [*a]
          name = name.to_s.sub(/^@/, '').to_sym
          opts = default_attr_options.merge(opts || {})
          [name, opts]
        end

        repeated_attrs = attrs.map(&:first)
          .tally
          .select { |_, count| count > 1 }
          .keys

        raise ArgumentError, "duplicated argument names: #{repeated_attrs.join(', ')}" if repeated_attrs.any?

        attrs.to_h
      end

      # @param [Hash[Symbol  Boolean]] attrs
      # @param [Hash[Symbol  Boolean]] kw_attrs
      private def define_initialize(attrs, kw_attrs)
        ->(*values, **kw_values) do

          unless attrs.size == values.size
            raise ArgumentError, "wrong number of arguments (given #{values.size}, expected #{attrs.size})"
          end

          missing_keys = kw_attrs.except(*kw_values.keys)
          unless missing_keys.empty?
            missing_keys = missing_keys.keys.map(&:inspect).join(', ')
            raise ArgumentError, "missing keywords: #{missing_keys}"
          end

          unknown_keywords = kw_values.except(*kw_attrs.keys)
          unless unknown_keywords.empty?
            unknown_keywords = unknown_keywords.keys.map(&:to_sym).map(&:inspect).join(', ')
            raise ArgumentError, "unknown keywords: #{unknown_keywords}"
          end

          attrs.keys.zip(values).each do |name, value|
            instance_variable_set "@#{name}", value
          end

          kw_values.each do |name, value|
            instance_variable_set "@#{name}", value
          end

        end
      end
    end

  end
end

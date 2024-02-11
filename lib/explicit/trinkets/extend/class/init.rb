# frozen_string_literal: true

module Trinkets
  module Class
    module Init
      Parameters = Struct.new(:req, :key_req, :key_opt, keyword_init: true)

      ATTR = %i[accessor reader writer none].freeze

      def init(*attrs, attr: ATTR.first, kw: false)
        attrs = Init.send(:sanitize_attrs, attrs, attr: attr, kw: kw)

        # @type [Hash[Symbol, Method]]
        attr_methods = (ATTR - [:none])
          .each_with_object({}) do |name, h|
            h[name] = method("attr_#{name}")
          end

        # even though options like `kw` aren't used, they serve here to validate the `attrs` options
        attr_init = ->(name, attr: ATTR.first, kw: false) do
          unless ATTR.include?(attr)
            raise ArgumentError, "wrong `attr` type for `#{name.inspect}` (given #{attr.inspect}, expected :accessor (default), :reader, :writer or :none)"
          end
          attr_methods[attr].call(name) unless attr == :none
        end

        attrs.each { |name, opts| attr_init.call(name, **opts) }

        # hash with 3 keys: {
        #   FalseClass => []  # positional args
        #   TrueClass  => []  # mandatory kw args
        #   Hash       => []  # optional kw args with default value
        # }
        grouped_params = attrs
          .map { |name, opts| [name, opts[:kw] || false] }
          .group_by { _1.last.class }

        params = Parameters.new(
          req:     [*grouped_params[FalseClass]].map(&:first),
          key_req: [*grouped_params[TrueClass]].map(&:first),
          key_opt: [*grouped_params[Hash]].to_h
                     .transform_values! { _1[:default] }
        )

        init_method = Init.send(:define_initialize, params)
        define_method :initialize, init_method
      end

      class << self
        private def sanitize_attrs(attrs, **default_options)

          raise ArgumentError, 'At least 1 attribute is required.' if attrs.empty?

          unless ::Trinkets::Class::Init::ATTR.include?(default_options[:attr])
            attr = default_options[:attr].inspect
            raise ArgumentError, "wrong `attr` type (given #{attr}, expected :accessor (default), :reader, :writer or :none)"
          end

          # Normalize attrs into an array: [[:name, **options], ...]
          # @type [Array[Array[Symbol, Hash]]]
          attrs = attrs.map do |a|
            name, opts = [*a]
            name = name.to_s.sub(/^@/, '').to_sym
            opts = default_options.merge(opts || {})
            [name, opts]
          end

          repeated_attrs = attrs.map(&:first)
            .tally
            .select { |_, count| count > 1 }
            .keys

          raise ArgumentError, "duplicated argument names: #{repeated_attrs.join(', ')}" if repeated_attrs.any?

          attrs.to_h
        end

        # @param [Parameters] params
        private def define_initialize(params)
          ->(*values, **kw_values) do

            unless params.req.size == values.size
              raise ArgumentError, "wrong number of arguments (given #{values.size}, expected #{params.req.size})"
            end

            missing_keys = params.key_req - kw_values.keys
            unless missing_keys.empty?
              missing_keys = missing_keys.map(&:inspect).join(', ')
              raise ArgumentError, "missing keywords: #{missing_keys}"
            end

            unknown_keywords = kw_values.except(*params.key_req, *params.key_opt.keys)
            unless unknown_keywords.empty?
              unknown_keywords = unknown_keywords.keys.map(&:to_sym).map(&:inspect).join(', ')
              raise ArgumentError, "unknown keywords: #{unknown_keywords}"
            end

            params.req.zip(values).each do |name, value|
              instance_variable_set "@#{name}", value
            end

            params.key_req.each do |name|
              instance_variable_set "@#{name}", kw_values[name]
            end

            params.key_opt.each do |name, default_value|
              value = kw_values.include?(name) ? kw_values[name] : default_value
              instance_variable_set "@#{name}", value
            end

          end
        end
      end
    end
  end
end

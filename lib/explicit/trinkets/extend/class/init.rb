# frozen_string_literal: true

module Trinkets
  module Class
    module Init
      ATTR = %i[accessor reader writer none].freeze
      Attribute = Struct.new(:name, :attr, :kw, keyword_init: true)
      Parameters = Struct.new(:req, :key_req, :key_opt, keyword_init: true)

      def init(*attrs, attr: ATTR.first, kw: false)
        attrs = Init.send(:sanitize_attrs, attrs, attr:, kw:)

        # @type [Hash[Symbol, Method]]
        attr_methods = (ATTR - [:none])
          .each_with_object({}) do |name, h|
            h[name] = method("attr_#{name}")
          end

        # even though options like `kw` aren't used, they serve here to validate the `attrs` options
        attr_init = ->(name, attr: ATTR.first, kw:) do
          unless ATTR.include?(attr)
            raise ArgumentError, "wrong `attr` type for `#{name.inspect}` (given #{attr.inspect}, expected :accessor (default), :reader, :writer or :none)"
          end
          attr_methods[attr].call(name) unless attr == :none
        end

        attrs.each { |param| attr_init.call(param.name, attr: param.attr, kw: param.kw) }

        # hash with 3 keys: {
        #   FalseClass => []  # positional args
        #   TrueClass  => []  # mandatory kw args
        #   Hash       => []  # optional kw args with default value
        # }
        grouped_params = attrs.group_by { |param| param.kw.class }

        params = Parameters.new(
          req:     grouped_params[FalseClass] || [],
          key_req: grouped_params[TrueClass]  || [],
          key_opt: grouped_params[Hash]       || []
        )

        init_method = Init.send(:define_initialize, params)
        define_method :initialize, init_method
      end

      class << self

        # @return [Array[Attribute]]
        private def sanitize_attrs(attrs, **default_options)

          raise ArgumentError, 'At least 1 attribute is required.' if attrs.empty?

          unless ::Trinkets::Class::Init::ATTR.include?(default_options[:attr])
            attr = default_options[:attr].inspect
            raise ArgumentError, "wrong `attr` type (given #{attr}, expected :accessor (default), :reader, :writer or :none)"
          end

          # @type [Array[Attribute]]
          attrs = attrs.map do |attr|
            name, opts = [*attr]
            name = name.to_s.sub(/^@/, '').to_sym

            opts ||= {}
            opts.reject! { |_, v| v.nil? }
            opts = default_options.merge(opts)

            Attribute.new(name:, **opts)
          end

          repeated_attrs = attrs.map(&:name)
            .tally
            .select { |_, count| count > 1 }
            .keys

          raise ArgumentError, "duplicated argument names: #{repeated_attrs.join(', ')}" if repeated_attrs.any?

          attrs
        end

        # @param [Parameters] params
        private def define_initialize(params)
          ->(*values, **kw_values) do

            unless params.req.size == values.size
              raise ArgumentError, "wrong number of arguments (given #{values.size}, expected #{params.req.size})"
            end

            key_req = params.key_req.map(&:name)
            missing_keys = key_req - kw_values.keys
            unless missing_keys.empty?
              missing_keys = missing_keys.map(&:inspect).join(', ')
              raise ArgumentError, "missing keywords: #{missing_keys}"
            end

            key_opt = params.key_opt.map(&:name)
            unknown_keywords = kw_values.except(*key_req, *key_opt)
            unless unknown_keywords.empty?
              unknown_keywords = unknown_keywords.keys.map(&:to_sym).map(&:inspect).join(', ')
              raise ArgumentError, "unknown keywords: #{unknown_keywords}"
            end

            params.req.zip(values).each do |param, value|
              instance_variable_set "@#{param.name}", value
            end

            params.key_req.each do |param|
              instance_variable_set "@#{param.name}", kw_values[param.name]
            end

            params.key_opt.each do |param|
              key, value = kw_values.assoc(param.name)
              value = param.kw[:default] unless key
              instance_variable_set "@#{param.name}", value
            end
          end
        end
      end
    end
  end
end

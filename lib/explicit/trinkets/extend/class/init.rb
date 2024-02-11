# frozen_string_literal: true

module Trinkets
  module Class
    module Init
      ATTR = %i[accessor reader writer none].freeze
      Attribute = Struct.new(:name, :attr, :kw, keyword_init: true)

      # @!attribute r req
      #   @return [Hash[Symbol, Attribute]]
      # @!attribute r key_req
      #   @return [Hash[Symbol, Attribute]]
      # @!attribute r key_opt
      #   @return [Hash[Symbol, Attribute]]
      class Parameters < Struct.new(:req, :key_req, :key_opt, keyword_init: true)

        def bind(values, kw_values)
          validate values, kw_values

          req = self.req.values.zip(values).each_with_object({}) do |(param, value), h|
            h[param.name] = BoundAttribute.new(
              name: param.name,
              attr: param.attr,
              kw: param.kw,
              value:
            )
          end

          key_req = self.key_req.values.each_with_object({}) do |param, h|
            h[param.name] = BoundAttribute.new(
              name: param.name,
              attr: param.attr,
              kw: param.kw,
              value: kw_values[param.name]
            )
          end

          key_opt = self.key_opt.values.each_with_object({}) do |param, h|
            key, value = kw_values.assoc(param.name)
            h[param.name] = BoundAttribute.new(
              name: param.name,
              attr: param.attr,
              kw: param.kw,
              value: key ? value : param.kw[:default]
            )
          end

          Parameters.new(req:, key_req:, key_opt:)

        end

        def all = req.merge(all_keys)

        def all_keys = key_req.merge(key_opt)

        private def validate(values, kw_values)

          unless req.size == values.size
            raise ArgumentError, "wrong number of arguments (given #{values.size}, expected #{req.size})"
          end

          missing_keys = key_req.keys - kw_values.keys
          unless missing_keys.empty?
            missing_keys = missing_keys.map(&:inspect).join(', ')
            raise ArgumentError, "missing keywords: #{missing_keys}"
          end

          unknown_keywords = kw_values.except(*key_req.keys, *key_opt.keys)
          unless unknown_keywords.empty?
            unknown_keywords = unknown_keywords.keys.map(&:to_sym).map(&:inspect).join(', ')
            raise ArgumentError, "unknown keywords: #{unknown_keywords}"
          end

        end
      end

      class BoundAttribute < Attribute

        attr_reader :value

        def initialize(name:, attr:, kw:, value:)
          super(name:, attr:, kw:)
          @value = value
        end
      end

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
        #   FalseClass => { :name => Attribute }  # positional args
        #   TrueClass  => { :name => Attribute }  # mandatory kw args
        #   Hash       => { :name => Attribute }  # optional kw args with default value
        # }
        grouped_attrs = attrs.group_by { |param| param.kw.class }
          .transform_values! do |params|
            params.each_with_object({}) { |p, h| h[p.name] = p }
          end

        params = Parameters.new(
          req:     grouped_attrs[FalseClass] || {},
          key_req: grouped_attrs[TrueClass]  || {},
          key_opt: grouped_attrs[Hash]       || {}
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

            params = params.bind(values, kw_values)

            params.all.each do |name, param|
              instance_variable_set "@#{name}", param.value
            end
          end
        end
      end
    end
  end
end

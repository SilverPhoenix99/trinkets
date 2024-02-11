# frozen_string_literal: true

module Trinkets
  module Class
    module Init
      ATTR = %i[accessor reader writer none].freeze

      class Parameter
        attr_reader :name, :attr, :kw, :super
        def initialize(name:, attr:, kw:, super:)
          @name  = name
          @attr  = attr
          @kw    = kw
          @super = [super:].first[:super]
        end
      end

      class BoundParameter < Parameter

        attr_reader :value

        def initialize(name:, attr:, kw:, super:, value:)
          super(name:, attr:, kw:, super:)
          @value = value
        end
      end

      # @!attribute r req
      #   @return [Array[Parameter]]
      # @!attribute r key_req
      #   @return [Array[Parameter]]
      # @!attribute r key_opt
      #   @return [Array[Parameter]]
      class Parameters < Struct.new(:req, :key_req, :key_opt, keyword_init: true)

        #@return [Parameters]
        def self.build(params, **default_options)

          raise ArgumentError, 'At least 1 attribute is required.' if params.empty?

          unless ::Trinkets::Class::Init::ATTR.include?(default_options[:attr])
            attr = default_options[:attr].inspect
            raise ArgumentError, "wrong `attr` type (given #{attr}, expected :accessor (default), :reader, :writer or :none)"
          end

          # @type [Array[Parameter]]
          params = params.map do |name, opts|
            name = name.to_s.sub(/^@/, '').to_sym

            opts ||= {}
            opts.reject! { |_, v| v.nil? }
            opts = default_options.merge(opts)

            Parameter.new(name:, **opts)
          end

          repeated_params = params.map(&:name)
            .tally
            .select { |_, count| count > 1 }
            .keys

          raise ArgumentError, "duplicated argument names: #{repeated_params.join(', ')}" if repeated_params.any?

          # hash with 3 keys: {
          #   FalseClass => { :name => Parameter }  # positional args
          #   TrueClass  => { :name => Parameter }  # mandatory kw args
          #   Hash       => { :name => Parameter }  # optional kw args with default value
          # }
          #@type [Hash[Class, Array[Parameter]]]
          params = params.group_by { |param| param.kw.class }

          Parameters.new(
            req:     [*params[FalseClass]],
            key_req: [*params[TrueClass]],
            key_opt: [*params[Hash]]
          )

        end

        #@return [Parameters]
        def bind(values, kw_values)

          validate values, kw_values

          req = self.req.zip(values).map do |(param, value)|
            BoundParameter.new(
              name: param.name,
              attr: param.attr,
              kw: param.kw,
              super: param.super,
              value:
            )
          end

          key_req = self.key_req.map do |param|
            BoundParameter.new(
              name: param.name,
              attr: param.attr,
              kw: param.kw,
              super: param.super,
              value: kw_values[param.name]
            )
          end

          key_opt = self.key_opt.map do |param|
            key, value = kw_values.assoc(param.name)
            BoundParameter.new(
              name: param.name,
              attr: param.attr,
              kw: param.kw,
              super: param.super,
              value: key ? value : param.kw[:default]
            )
          end

          Parameters.new(req:, key_req:, key_opt:)

        end

        def all_params = req + all_key_params

        def all_key_params = key_req + key_opt

        private def validate(values, kw_values)

          unless req.size == values.size
            raise ArgumentError, "wrong number of arguments (given #{values.size}, expected #{req.size})"
          end

          missing_keys = key_req.map(&:name) - kw_values.keys
          unless missing_keys.empty?
            missing_keys = missing_keys.map(&:inspect).join(', ')
            raise ArgumentError, "missing keywords: #{missing_keys}"
          end

          unknown_keywords = kw_values.except(*all_key_params.map(&:name))
          unless unknown_keywords.empty?
            unknown_keywords = unknown_keywords.keys.map(&:to_sym).map(&:inspect).join(', ')
            raise ArgumentError, "unknown keywords: #{unknown_keywords}"
          end

        end
      end

      def init(*params, attr: ATTR.first, kw: false, super: false)

        params = Parameters.build(params, attr:, kw:, super:)

        # @type [Hash[Symbol, Method]]
        attr_methods = (ATTR - [:none])
          .each_with_object({}) do |name, h|
            h[name] = method("attr_#{name}")
          end

        attr_init = ->(name, attr: ATTR.first) do
          unless ATTR.include?(attr)
            raise ArgumentError, "wrong `attr` type for `#{name.inspect}` (given #{attr.inspect}, expected :accessor (default), :reader, :writer or :none)"
          end
          attr_methods[attr].call(name) unless attr == :none
        end

        params.all_params.each do |param|
          attr_init.call param.name, attr: param.attr
        end

        init_method = Init.send(:define_initialize, params)
        define_method :initialize, init_method
      end

      class << self

        # @param [Parameters] params
        private def define_initialize(params)
          ->(*values, **kw_values) do

            params = params.bind(values, kw_values)

            super_req = params.req.select(&:super).map(&:value)
            super_kws = params.all_key_params.select(&:super)
              .each_with_object({}) do |param, h|
                h[param.name] = param.value
              end

            super *super_req, **super_kws

            params.all_params.each do |param|
              name = "@#{param.name}"
              instance_variable_set(name, param.value) unless instance_variable_defined?(name)
            end
          end
        end
      end
    end
  end
end

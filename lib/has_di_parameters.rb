# frozen_string_literal: true

#
# The HasDIParameters module is used to allow for a hash of key/value pairs to be passed in for initialization
# and create methods corresponding to these automatically. Optionally, default key/value pairs can be set. (see below)
#
# The purpose of this is to simplify interfaces and allow for configuration methods to be called directly.
#
# For example, given the simple class:
# class Base
#   include HasDIParameters
#
#   def call
#     puts json
#   end
# end
#
# and calling this with:
#   Base.call({min: 1000, max: 10000, json: {inner: 'wibble'}, other: nil })
#
#   or
#
#   base_object = Base.new({min: 1000, max: 10000, json: {inner: 'wibble'}, other: nil })
#   base.object.call
#
# would result in:
#
# {inner: 'wibble'}
#
# as an output.
#
# There are new "#min", "#max", "#json" and '#other' methods created in the base class which will return the values
# set in the config variable directly. This is a shallow generation, so hashes inside the original are preserved.
#
# Options that can be overridden in the class are:
#
# `prevent_local_override`
# As a declaration, this will prevent any defined methods from being obscured by hash keys with the same name
# These will just be skipped.
#
# def default_config
#   <Hash with values required as defaults if missing>
# end
#
# This will allow default values to be set, which will also generate key/value methods.
#

require "active_support"
require "active_support/core_ext"

module HasDIParameters
  class MissingRequiredArguments < RuntimeError; end

  attr_accessor :params

  class << self
    def included(base)
      base.class_eval do
        extend InitialiseClassConfig
      end
    end
  end

  def call(*)
    raise "override abstract call method"
  end

  def default_params
    {}
  end

  def required_params
    self.class.required_params
  end

private

  # @param [Hash] config
  def initialize(config)
    inject_params(config)
  end

  def inject_params(config)
    self.class.externally_injected ||= []
    self.params = HashWithIndifferentAccess.new(config.respond_to?(:[]) ? default_params.merge(config) : default_params)
    params.each do |key, value|
      auto_define(key) { value } unless allow_override? && respond_to?(key)
    end
    check_required
  end

  def check_required
    raise ::HasDIParameters::MissingRequiredArguments, "missing required dependency injected items #{missing_required_params} in class #{self.class.name}" unless missing_required_params.empty?
  end

  def missing_required_params
    self.class.externally_injected.reject { |name| respond_to?(name) }
  end

  def auto_define(key, &value)
    singleton_class.instance_eval { define_method key, &value }
  end

  def allow_override?
    !self.class.prevent_override
  end

  module InitialiseClassConfig
    include ActiveSupport
    attr_accessor :prevent_override, :externally_injected

    def prevent_local_override
      self.prevent_override = true
    end

    def required_params(*args)
      return @externally_injected || [] if args.nil?

      self.externally_injected = args
    end

    # @param [Hash] config
    # @param [Object] args
    def call(config, **args)
      new(config).call(**args)
    end
  end
end

# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"

module InitializeWithConfig
  attr_accessor :config

  class << self
    def included(base)
      base.class_eval do
        extend InitialiseClassConfig
      end
    end
  end

  def call
    raise "override abstract call method"
  end

private
  def initialize(config)
    self.config = config.is_a?(Hash) ? OpenStruct.new(config) : config
    config.each do |key, value|
      auto_define(key) { value } unless allow_override? && respond_to?(key)
    end
  end

  def auto_define(key, &value)
    singleton_class.instance_eval { define_method key, &value }
  end

  def allow_override?
    !self.class.prevent_override
  end

  module InitialiseClassConfig
    include ActiveSupport
    attr_accessor :prevent_override

    def prevent_local_override
      self.prevent_override = true
    end

    def call(config)
      new(config).call
    end
  end
end

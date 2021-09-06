# frozen_string_literal: true

module AbstractInterface
  extend ActiveSupport::Concern

  included do
    extend AbstractInterfaceClassMethods
  end

  module AbstractInterfaceClassMethods
    def implement_class_method(*methods)
      methods.each do |key|
        define_singleton_method(key) { raise NotImplementedError, "Class method #{key} must be implemented" } unless self.class.respond_to?(key)
      end
    end

    def implement_instance_method(*methods)
      methods.each do |key|
        define_method(key) { raise NotImplementedError, "Instance method #{key} must be implemented" } unless respond_to?(key)
      end
    end
  end
end

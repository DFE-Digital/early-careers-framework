# frozen_string_literal: true

module AbstractInterface
  extend ActiveSupport::Concern

  included do
    extend AbstractInterfaceClassMethods
  end

  module AbstractInterfaceClassMethods
    def implement_class_method(*methods)
      methods.each do |key|
        instance_method_define(key) { raise NotImplementedError, "Method must be implemented" } unless self.class.respond_to?(key)
      end
    end

    def implement_instance_method(*methods)
      methods.each do |key|
        class_method_define(key) { raise NotImplementedError, "Method must be implemented" } unless respond_to?(key)
      end
    end

    def instance_method_define(key, &value)
      singleton_class.instance_eval { define_method key, &value }
    end

    def class_method_define(key, &value)
      singleton_class.class_eval { define_method key, &value }
    end
  end
end

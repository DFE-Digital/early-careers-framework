# frozen_string_literal: true

require "rails_helper"
require "abstract_interface"

RSpec.describe AbstractInterface do
  context "when defining a required class method condition" do
    it "succeeds" do
      test_class = Class.new do
        include AbstractInterface
        implement_class_method :wibble, :wobble
      end

      expect { test_class.wibble }.to raise_error(NotImplementedError)
      expect { test_class.wobble }.to raise_error(NotImplementedError)
      expect { test_class.new.wibble }.to raise_error(NoMethodError)
    end
  end

  context "when defining a required instance method condition" do
    it "succeeds" do
      test_class = Class.new do
        include AbstractInterface
        implement_instance_method :wibble
      end

      expect { test_class.new.wibble }.to raise_error(NotImplementedError)
      expect { test_class.wibble }.to raise_error(NoMethodError)
    end
  end
end

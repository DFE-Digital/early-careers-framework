# frozen_string_literal: true

require "rails_helper"

RSpec.describe Withdrawn::ECFValidator do
  subject do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :reason
      validates :reason, "withdrawn/ecf": true
    end
  end

  context "when passed bad reasons" do
    ["", nil, "not a good reason"].each do |reason|
      describe "when reason is #{reason}" do
        it "adds a validation error" do
          instance = subject.new
          instance.reason = reason
          instance.validate
          expect(instance.errors[:reason]).to include "Cannot withdraw without a valid reason"
        end
      end
    end
  end

  context "when passed good reasons" do
    described_class.reasons.each do |reason|
      describe "when reason is #{reason}" do
        it "adds a validation error" do
          instance = subject.new
          instance.reason = reason
          instance.validate
          expect(instance.errors[:reason]).to_not include "Cannot withdraw without a valid reason"
        end
      end
    end
  end
end

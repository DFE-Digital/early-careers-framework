# frozen_string_literal: true

require "rails_helper"

RSpec.describe FinanceHelper do
  describe "#number_to_pounds" do
    context "when negative zero" do
      it "returns unsigned zero" do
        expect(helper.number_to_pounds(BigDecimal("-0"))).to eql("£0.00")
      end
    end
  end
end

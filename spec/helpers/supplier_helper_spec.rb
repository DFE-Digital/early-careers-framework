# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupplierHelper, type: :helper do
  let(:lead_provider) { create(:lead_provider) }
  let(:delivery_partner) { create(:delivery_partner) }

  describe "#supplier_link" do
    context "when the supplier is a lead provider" do
      it "returns nil" do
        expect(helper.supplier_link(lead_provider)).to be_nil
      end
    end

    context "when the supplier is an delivery partner" do
      let(:result) { "/admin/suppliers/delivery-partners/#{delivery_partner.id}" }

      it "returns the admin url for the delivery partner" do
        expect(helper.supplier_link(delivery_partner)).to eq(result)
      end
    end
  end
end

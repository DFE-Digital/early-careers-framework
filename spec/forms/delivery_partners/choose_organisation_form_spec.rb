# frozen_string_literal: true

RSpec.describe DeliveryPartners::ChooseOrganisationForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:params) { { user:, delivery_partner_id: form_delivery_partner_id } }
  let(:form_delivery_partner_id) { nil }
  let(:user) { create(:user) }

  describe "#delivery_partner" do
    let!(:delivery_partner_profile) { create(:delivery_partner_profile, user:) }
    let(:form_delivery_partner_id) { delivery_partner_profile.delivery_partner.id }

    it "returns delivery_partner" do
      expect(form.delivery_partner).to eql(delivery_partner_profile.delivery_partner)
    end
  end

  describe "#only_one" do
    describe "one appropriate body" do
      let!(:delivery_partner_profile1) { create(:delivery_partner_profile, user:) }

      it "returns true" do
        expect(form.only_one).to be true
        expect(form.delivery_partner).to eql(delivery_partner_profile1.delivery_partner)
      end
    end

    describe "multiple appropriate bodies" do
      let!(:delivery_partner_profile1) { create(:delivery_partner_profile, user:) }
      let!(:delivery_partner_profile2) { create(:delivery_partner_profile, user:) }
      let!(:delivery_partner_profile3) { create(:delivery_partner_profile, user:) }

      it "returns false" do
        expect(form.only_one).to be false
      end
    end
  end

  describe "#delivery_partner_options" do
    let!(:delivery_partner_profile1) { create(:delivery_partner_profile, user:) }
    let!(:delivery_partner_profile2) { create(:delivery_partner_profile, user:) }
    let!(:delivery_partner_profile3) { create(:delivery_partner_profile, user:) }

    it "returns form options" do
      expect(form.delivery_partner_options).to include(
        delivery_partner_profile1.delivery_partner.id => delivery_partner_profile1.delivery_partner.name,
        delivery_partner_profile2.delivery_partner.id => delivery_partner_profile2.delivery_partner.name,
        delivery_partner_profile3.delivery_partner.id => delivery_partner_profile3.delivery_partner.name,
      )
    end
  end
end

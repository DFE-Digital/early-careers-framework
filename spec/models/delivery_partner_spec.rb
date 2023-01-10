# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartner, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  it "can be created" do
    expect {
      DeliveryPartner.create(name: "Delivery Partner")
    }.to change { DeliveryPartner.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to have_many(:provider_relationships) }
    it { is_expected.to have_many(:lead_providers).through(:provider_relationships) }
    it { is_expected.to have_many(:partnership_csv_uploads) }
    it { is_expected.to have_many(:partnerships) }
    it { is_expected.to have_many(:active_partnerships) }
    it { is_expected.to have_many(:schools).through(:active_partnerships) }
    it { is_expected.to have_many(:delivery_partner_profiles) }
    it { is_expected.to have_many(:users) }
  end

  describe "#cohorts_with_lead_provider" do
    let(:delivery_partner)   { create(:delivery_partner) }
    let(:partnered_cohort)   { Cohort.current || create(:cohort, :current) }
    let(:unpartnered_cohort) { Cohort.next || create(:cohort, :next) }
    let(:lead_provider)      { create(:lead_provider, cohorts: [partnered_cohort, unpartnered_cohort]) }

    before do
      ProviderRelationship.create!(
        delivery_partner:,
        lead_provider:,
        cohort: partnered_cohort,
      )
    end

    it "includes a cohort for a lead provider where a provider relationship exists" do
      expect(delivery_partner.cohorts_with_provider(lead_provider)).to include(partnered_cohort)
    end

    it "does not include a cohort for a lead provider where no provider relationship exists" do
      expect(delivery_partner.cohorts_with_provider(lead_provider)).not_to include(unpartnered_cohort)
    end
  end

  describe "participant_profiles", :with_default_schedules do
    let(:delivery_partner) { create(:delivery_partner) }
    let(:lead_provider)    { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider).lead_provider }
    let(:school_cohort)    { create(:school_cohort, :with_induction_programme, delivery_partner:, lead_provider:) }

    it "should include active participants" do
      participant_profile = create(:ect, school_cohort:, lead_provider:)
      expect(delivery_partner.ecf_participant_profiles).to include participant_profile
    end

    it "should include participants whose records have been withdrawn" do
      participant_profile = create(:ect, :withdrawn_record, school_cohort:, lead_provider:)
      expect(delivery_partner.ecf_participant_profiles).to include participant_profile
    end

    it "should include mentors" do
      participant_profile = create(:mentor, school_cohort:, lead_provider:)
      expect(delivery_partner.ecf_participant_profiles).to include participant_profile
    end

    it "should not include NPQ participants" do
      participant_profile = create(:npq_participant_profile, npq_lead_provider: lead_provider.cpd_lead_provider.npq_lead_provider)
      expect(delivery_partner.ecf_participant_profiles).not_to include participant_profile
    end
  end

  describe "active_ecf_participant_profiles", :with_default_schedules do
    let(:delivery_partner) { create(:delivery_partner) }
    let(:lead_provider)    { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider).lead_provider }
    let(:school_cohort)    { create(:school_cohort, :with_induction_programme, delivery_partner:, lead_provider:) }

    it "should include active participants" do
      participant_profile = create(:ect, school_cohort:, lead_provider:)
      expect(delivery_partner.active_ecf_participant_profiles).to include participant_profile
    end

    it "should not include participants whose records have been withdrawn" do
      participant_profile = create(:ect, :withdrawn_record, school_cohort:, lead_provider:)
      expect(delivery_partner.active_ecf_participant_profiles).not_to include participant_profile
    end

    it "should not include NPQ participants" do
      participant_profile = create(:npq_participant_profile, npq_lead_provider: lead_provider.cpd_lead_provider.npq_lead_provider)
      expect(delivery_partner.active_ecf_participant_profiles).not_to include participant_profile
    end
  end

  describe "soft delete" do
    let!(:delivery_partner) { create(:delivery_partner) }
    it "can be discarded" do
      delivery_partner.discard

      expect(delivery_partner.discarded?).to be true
    end

    it "is not returned in the default scope when discarded" do
      delivery_partner.discard

      expect(DeliveryPartner.all).not_to include(delivery_partner)
    end

    it "is returned in the with_discarded scope when discarded" do
      delivery_partner.discard

      expect(DeliveryPartner.with_discarded).to include(delivery_partner)
    end

    it "does not increase the count when discarded" do
      expect { delivery_partner.discard }.to change { DeliveryPartner.count }.by(-1)
    end
  end
end

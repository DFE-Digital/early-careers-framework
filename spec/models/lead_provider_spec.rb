# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProvider, type: :model do
  it "can be created" do
    expect {
      LeadProvider.create(name: "Test Lead Provider")
    }.to change { LeadProvider.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider).required(false) }

    it { is_expected.to have_many(:partnerships) }
    it { is_expected.to have_many(:schools).through(:active_partnerships) }
    it { is_expected.to have_many(:lead_provider_profiles) }
    it { is_expected.to have_many(:users).through(:lead_provider_profiles) }
    it { is_expected.to have_many(:provider_relationships) }
    it { is_expected.to have_many(:delivery_partners).through(:provider_relationships) }
    it { is_expected.to have_many(:partnership_csv_uploads) }
    it { is_expected.to have_many(:participation_records) }
    it { is_expected.to have_one(:call_off_contract) }

    describe "active_partnerships" do
      it "should not include pending partnerships" do
        partnership = create(:partnership, :pending)
        expect(partnership.lead_provider.active_partnerships).not_to include partnership
      end

      it "should not include challenged partnerships" do
        partnership = create(:partnership, :challenged)
        expect(partnership.lead_provider.active_partnerships).not_to include partnership
      end

      it "should include active partnerships" do
        partnership = create(:partnership)
        expect(partnership.lead_provider.active_partnerships).to include partnership
      end
    end

    describe "participant_profiles" do
      let(:partnership) { create(:partnership) }
      let(:school) { partnership.school }
      let(:lead_provider) { partnership.lead_provider }

      it "should include active participants" do
        participant_profile = create(:participant_profile, :ect, school: school)
        expect(lead_provider.participant_profiles).to include participant_profile
      end

      it "should include withdrawn participants" do
        participant_profile = create(:participant_profile, :ect, status: "withdrawn", school: school)
        expect(lead_provider.participant_profiles).to include participant_profile
      end

      it "should include mentors" do
        participant_profile = create(:participant_profile, :mentor, school: school)
        expect(lead_provider.participant_profiles).to include participant_profile
      end

      it "should not include NPQ participants" do
        participant_profile = create(:participant_profile, :npq, school_id: school.id)
        expect(lead_provider.participant_profiles).not_to include participant_profile
      end
    end

    describe "active_participant_profiles" do
      let(:partnership) { create(:partnership) }
      let(:school) { partnership.school }
      let(:lead_provider) { partnership.lead_provider }

      it "should include active participants" do
        participant_profile = create(:participant_profile, :ect, school: school)
        expect(lead_provider.active_participant_profiles).to include participant_profile
      end

      it "should not include withdrawn participants" do
        participant_profile = create(:participant_profile, :ect, school: school, status: "withdrawn")
        expect(lead_provider.active_participant_profiles).not_to include participant_profile
      end

      it "should not include NPQ participants" do
        participant_profile = create(:participant_profile, :npq, school_id: school.id)
        expect(lead_provider.active_participant_profiles).not_to include participant_profile
      end
    end
  end
end

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
    it { is_expected.to have_many(:mentor_call_off_contracts) }
    it { is_expected.to have_many(:statements).through(:cpd_lead_provider).class_name("Finance::Statement::ECF").source(:ecf_statements) }

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
      let(:school) { partnership.school }
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:lead_provider) { cpd_lead_provider.lead_provider }
      let(:partnership) { create(:partnership, lead_provider:) }
      let(:school_cohort) { create(:school_cohort, school:) }

      it "should include active participants" do
        participant_profile = create(:ect, school_cohort:, lead_provider:)
        expect(lead_provider.ecf_participant_profiles).to include participant_profile
      end

      it "should include participants whose records have been withdrawn" do
        participant_profile = create(:ect, :withdrawn_record, school_cohort:, lead_provider:)
        expect(lead_provider.ecf_participant_profiles).to include participant_profile
      end

      it "should include mentors" do
        participant_profile = create(:mentor, school_cohort:, lead_provider:)
        expect(lead_provider.ecf_participant_profiles).to include participant_profile
      end
    end

    describe "active_ecf_participant_profiles" do
      let(:partnership) { create(:partnership) }
      let(:school) { partnership.school }
      let(:lead_provider) { partnership.lead_provider }
      let(:school_cohort) { create(:school_cohort, school:) }

      it "should include active participants" do
        participant_profile = create(:ect_participant_profile, school_cohort:)
        expect(lead_provider.active_ecf_participant_profiles).to include participant_profile
      end

      it "should not include participants whose records have been withdrawn" do
        participant_profile = create(:ect_participant_profile, :withdrawn_record, school_cohort:)
        expect(lead_provider.active_ecf_participant_profiles).not_to include participant_profile
      end
    end

    describe "#first_training_year" do
      let(:cohort_1) { Cohort.previous || create(:cohort, :previous) }
      let(:cohort_2) { Cohort.current || create(:cohort, :current) }
      let(:lead_provider) { create(:lead_provider) }

      context "when the lead provider has no relationships with any delivery_partner" do
        it "return nil" do
          expect(lead_provider.first_training_year).to be_nil
        end
      end

      context "when the lead provider has relationships with delivery_partners" do
        before do
          create(:provider_relationship, lead_provider:, cohort: cohort_1)
          create(:provider_relationship, lead_provider:, cohort: cohort_2)
        end

        it "return the year of the earliest relationship" do
          expect(lead_provider.first_training_year).to eq(cohort_1.start_year)
        end
      end
    end

    describe "#providing_training?" do
      let(:cohort) { Cohort.current || create(:cohort, :current) }
      let(:lead_provider) { create(:lead_provider) }

      context "when the lead provider has no relationships with any delivery_partner on the cohort" do
        it "return false" do
          expect(lead_provider.providing_training?(cohort)).to be_falsey
        end
      end

      context "when the lead provider has at least one relationship with a delivery_partner on the cohort" do
        before do
          create(:provider_relationship, lead_provider:, cohort:)
        end

        it "return false" do
          expect(lead_provider.providing_training?(cohort)).to be_truthy
        end
      end
    end
  end

  describe "scopes" do
    describe "name_order" do
      let!(:provider_one) { FactoryBot.create(:lead_provider, name: "Lead Provider Example") }
      let!(:provider_two) { FactoryBot.create(:lead_provider, name: "Another Lead Provider Example") }

      it "returns all providers in name order" do
        expect(described_class.name_order).to eq([provider_two, provider_one])
      end
    end
  end
end

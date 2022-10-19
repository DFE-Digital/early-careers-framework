# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ECF, with_feature_flags: { multiple_cohorts: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { create(:cohort) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:school_cohort) { create(:school_cohort, school: partnership.school, cohort:) }
  let(:induction_programme) { create(:induction_programme, school_cohort:, partnership:) }
  let(:user_profile) { create(:ecf_participant_profile, school_cohort:) }
  let!(:induction_record) { create(:induction_record, participant_profile: user_profile, induction_programme:) }

  let(:test_ecf_participants) do
    Class.new do
      include Participants::ECF

      attr_reader :cpd_lead_provider, :user_profile

      def initialize(cpd_lead_provider:, user_profile:)
        @cpd_lead_provider = cpd_lead_provider
        @user_profile = user_profile
      end
    end
  end

  before do
    stub_const("TestECFParticipants", test_ecf_participants)
  end

  describe "#matches_lead_provider?" do
    it "returns true if induction record exists for lead provider" do
      service = TestECFParticipants.new(cpd_lead_provider:, user_profile:)

      expect(service.matches_lead_provider?).to be(true)
    end

    it "returns false if induction record does not exist for lead provider" do
      another_cpd_lead_provider = create(:cpd_lead_provider, :with_lead_provider)
      service = TestECFParticipants.new(cpd_lead_provider: another_cpd_lead_provider, user_profile:)

      expect(service.matches_lead_provider?).to be(false)
    end
  end

  describe "#relevant_induction_record" do
    let(:service) { TestECFParticipants.new(cpd_lead_provider:, user_profile:) }

    context "when cohort start year is the same year as induction programme start" do
      it "returns the induction record matching user, cohort and lead provider" do
        expect(service.relevant_induction_record).to eq(induction_record)
      end
    end
    context "when another cohort exists with with start year ahead of the induction programme start" do
      let(:cohort) { create(:cohort, :next) }

      it "returns the induction record matching user, cohort and lead provider" do
        expect(service.relevant_induction_record).to eq(induction_record)
      end
    end
  end
end

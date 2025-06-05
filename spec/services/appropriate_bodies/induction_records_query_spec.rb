# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodies::InductionRecordsQuery, mid_cohort: true do
  let(:appropriate_body_user) { create(:user, :appropriate_body) }
  let(:appropriate_body) { appropriate_body_user.appropriate_bodies.first }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:partnership) do
    create(
      :partnership,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
    )
  end
  let(:induction_programme) { create(:induction_programme, partnership:) }
  let!(:induction_record) { create(:induction_record, participant_profile:, appropriate_body:, induction_programme:) }

  subject { described_class.new(appropriate_body:) }

  describe "#induction_records" do
    before do
      # Later induction record for different appropriate body (should be ignored)
      create(:induction_record, participant_profile:, induction_programme:)

      # Mentor for same appropriate body (should be excluded)
      mentor_profile = create(:mentor_participant_profile)
      create(:induction_record, participant_profile: mentor_profile, appropriate_body:, induction_programme:)

      # ECT not in active registration cohort (should be excluded)
      other_cohort = Cohort.find_by(start_year: 2021)
      other_participant_profile = create(:ect_participant_profile, cohort: other_cohort)
      school_cohort = create(:school_cohort, cohort: other_cohort)
      other_induction_programme = create(:induction_programme, :fip)
      create(:induction_record, participant_profile: other_participant_profile, appropriate_body:, induction_programme: other_induction_programme, school_cohort:)
    end

    it_behaves_like "a query optimised for calculating training record states", mentor_optimization: false

    it "returns latest induction record for appropriate body" do
      expect(subject.induction_records).to match_array([induction_record])
    end

    context "when there are more induction records for the same appropriate body" do
      let!(:latest_induction_record) do
        travel_to(1.day.from_now) do
          create(:induction_record, participant_profile:, appropriate_body:, induction_programme:)
        end
      end

      it "returns latest induction record for appropriate body" do
        expect(subject.induction_records).to match_array([latest_induction_record])
      end
    end

    context "when there are newer induction records for a different appropriate body" do
      let!(:latest_induction_record) { create(:induction_record, participant_profile:, induction_programme:, training_status: "deferred") }

      it "returns correct induction record for appropriate body" do
        expect(subject.induction_records).to match_array([induction_record])
      end
    end
  end
end

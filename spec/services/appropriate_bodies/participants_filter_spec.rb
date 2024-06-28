# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodies::ParticipantsFilter do
  let(:cohort) { Cohort.active_registration_cohort }
  let(:appropriate_body_user) { create(:user, :appropriate_body) }
  let(:appropriate_body) { appropriate_body_user.appropriate_bodies.first }

  let(:participant_profile1) { create(:ect_participant_profile, cohort:) }
  let(:school_cohort1) { create(:school_cohort, cohort:) }
  let(:induction_programme1) { create(:induction_programme, :fip) }
  let!(:induction_record1) { create(:induction_record, participant_profile: participant_profile1, appropriate_body:, induction_programme: induction_programme1, school_cohort: school_cohort1) }

  let(:participant_profile2) { create(:ect_participant_profile, training_status: "deferred") }
  let(:school_cohort2) { create(:school_cohort, cohort:) }
  let(:induction_programme2) { create(:induction_programme, :cip) }
  let!(:induction_record2) { create(:induction_record, participant_profile: participant_profile2, appropriate_body:, induction_programme: induction_programme2, training_status: "deferred", school_cohort: school_cohort2) }

  # participant to be ignored
  let(:older_cohort) { Cohort.find_by(start_year: 2021) }
  let(:another_participant_profile) { create(:ect_participant_profile, cohort: older_cohort) }
  let(:another_school_cohort) { create(:school_cohort, cohort: older_cohort) }
  let(:another_induction_programme) { create(:induction_programme, :fip) }
  let!(:another_induction_record) { create(:induction_record, participant_profile: another_participant_profile, appropriate_body:, induction_programme: another_induction_programme, school_cohort: another_school_cohort) }

  let(:collection) { AppropriateBodies::InductionRecordsQuery.new(appropriate_body:).induction_records }
  let(:params) { {} }
  let(:training_record_states) { DetermineTrainingRecordState.call(induction_records: collection) }

  subject { described_class.new(collection:, params:, training_record_states:).scope.to_a }

  context "No filter" do
    it { is_expected.to match_array([induction_record1, induction_record2]) }
  end

  context "Search filter" do
    context "by full name" do
      let(:params) { { query: participant_profile2.user.full_name } }

      it { is_expected.to match_array([induction_record2]) }
    end

    context "by school name" do
      let(:params) { { query: induction_record1.school.name } }

      it { is_expected.to match_array([induction_record1]) }
    end

    context "by school URN" do
      let(:params) { { query: induction_record2.school.urn } }

      it { is_expected.to match_array([induction_record2]) }
    end

    context "by TRN" do
      let(:params) { { query: participant_profile1.teacher_profile.trn } }

      it { is_expected.to match_array([induction_record1]) }
    end
  end

  context "Status filter" do
    context "Filter by participant_deferred" do
      let(:params) { { status: "participant_deferred" } }

      it { is_expected.to match_array([induction_record2]) }
    end

    context "Filter by dfe_checking_eligibility" do
      let(:params) { { status: "dfe_checking_eligibility" } }

      it { is_expected.to match_array([induction_record1]) }
    end

    context "Filter by contacted_for_information" do
      let(:params) { { status: "contacted_for_information" } }

      it { is_expected.to be_empty }
    end
  end
end

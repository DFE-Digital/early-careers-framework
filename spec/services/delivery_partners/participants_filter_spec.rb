# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartners::ParticipantsFilter do
  let(:school_cohort1) { create(:school_cohort, cohort: Cohort.current) }
  let(:partnership1) { create(:partnership, lead_provider: create(:lead_provider, name: "LP1")) }
  let(:induction_programme1) { create(:induction_programme, partnership: partnership1) }
  let(:participant_profile1) { create(:mentor_participant_profile) }
  let!(:induction_record1) { create(:induction_record, participant_profile: participant_profile1, induction_programme: induction_programme1, school_cohort: school_cohort1) }

  let(:school_cohort2) { create(:school_cohort, cohort: Cohort.next) }
  let(:partnership2) { create(:partnership, lead_provider: create(:lead_provider, name: "LP2")) }
  let(:induction_programme2) { create(:induction_programme, partnership: partnership2) }
  let(:participant_profile2) { create(:ect_participant_profile, training_status: "deferred") }
  let!(:induction_record2) { create(:induction_record, participant_profile: participant_profile2, induction_programme: induction_programme2, school_cohort: school_cohort2, training_status: "deferred") }

  let(:delivery_partner) { create(:delivery_partner, partnerships: [partnership1, partnership2]) }

  let(:collection) { DeliveryPartners::InductionRecordsQuery.new(delivery_partner:).induction_records }
  let(:params) { {} }
  let(:training_record_states) { DetermineTrainingRecordState.call(induction_records: collection) }

  subject { described_class.new(collection:, params:, training_record_states:).scope.to_a }

  context "when there are no filters provided" do
    it { is_expected.to contain_exactly(induction_record1, induction_record2) }
  end

  context "when filtering by query" do
    context "with unmatched query" do
      let(:params) { { query: "unmatched" } }

      it { is_expected.to be_empty }
    end

    context "with full name" do
      let(:params) { { query: participant_profile2.user.full_name } }

      it { is_expected.to contain_exactly(induction_record2) }
    end

    context "with email" do
      let(:params) { { query: participant_profile1.user.email } }

      it { is_expected.to contain_exactly(induction_record1) }
    end

    context "with lead provider" do
      let(:params) { { query: partnership2.lead_provider_name } }

      it { is_expected.to contain_exactly(induction_record2) }
    end

    context "with school name" do
      let(:params) { { query: induction_record1.school.name } }

      it { is_expected.to contain_exactly(induction_record1) }
    end

    context "with school URN" do
      let(:params) { { query: induction_record2.school.urn } }

      it { is_expected.to contain_exactly(induction_record2) }
    end

    context "with TRN" do
      let(:params) { { query: participant_profile1.teacher_profile.trn } }

      it { is_expected.to contain_exactly(induction_record1) }
    end
  end

  context "when filtering by role" do
    context "when role is not ect/mentor" do
      let(:params) { { role: "other" } }

      it { is_expected.to contain_exactly(induction_record1, induction_record2) }
    end

    context "when role is ect" do
      let(:params) { { role: "ect" } }

      it { is_expected.to contain_exactly(induction_record2) }
    end

    context "when role is mentor" do
      let(:params) { { role: "mentor" } }

      it { is_expected.to contain_exactly(induction_record1) }
    end
  end

  context "when filtering by academic_year" do
    context "with unmatched academic_year" do
      let(:params) { { academic_year: 1999 } }

      it { is_expected.to be_empty }
    end

    context "with academic_year" do
      let(:params) { { academic_year: school_cohort1.start_year } }

      it { is_expected.to contain_exactly(induction_record1) }
    end
  end

  context "when filtering by status" do
    context "when status is not matched" do
      let(:params) { { status: "contacted_for_information" } }

      it { is_expected.to be_empty }
    end

    context "when status is participant_deferred" do
      let(:params) { { status: "participant_deferred" } }

      it { is_expected.to contain_exactly(induction_record2) }
    end

    context "when status is dfe_checking_eligibility" do
      let(:params) { { status: "dfe_checking_eligibility" } }

      it { is_expected.to contain_exactly(induction_record1) }
    end
  end
end

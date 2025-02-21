# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartners::ParticipantsFilter do
  let(:latest_start_year_returned) { DeliveryPartners::ParticipantsFilter::LATEST_COHORT_TO_RETURN }
  let(:excluded_start_year) { latest_start_year_returned + 1 }

  let(:school_cohort1) { create(:school_cohort, cohort: Cohort.find_by!(start_year: latest_start_year_returned - 1)) }
  let(:partnership1) { create(:partnership, lead_provider: create(:lead_provider, name: "LP1")) }
  let(:induction_programme1) { create(:induction_programme, partnership: partnership1) }
  let(:participant_profile1) { create(:mentor_participant_profile) }
  let!(:induction_record1) { create(:induction_record, participant_profile: participant_profile1, induction_programme: induction_programme1, school_cohort: school_cohort1) }

  let(:school_cohort2) { create(:school_cohort, cohort: Cohort.find_by!(start_year: latest_start_year_returned)) }
  let(:partnership2) { create(:partnership, lead_provider: create(:lead_provider, name: "LP2")) }
  let(:induction_programme2) { create(:induction_programme, partnership: partnership2) }
  let(:participant_profile2) { create(:ect_participant_profile, training_status: "deferred") }
  let!(:induction_record2) { create(:induction_record, participant_profile: participant_profile2, induction_programme: induction_programme2, school_cohort: school_cohort2, training_status: "deferred") }

  let(:school_cohort3) { create(:school_cohort, cohort: Cohort.find_by!(start_year: excluded_start_year)) }
  let(:partnership3) { create(:partnership, lead_provider: create(:lead_provider, name: "LP3")) }
  let(:induction_programme3) { create(:induction_programme, partnership: partnership3) }
  let(:participant_profile3) { create(:ect_participant_profile, training_status: "deferred") }
  let!(:induction_record3) { create(:induction_record, participant_profile: participant_profile3, induction_programme: induction_programme3, school_cohort: school_cohort3) }

  let(:delivery_partner) { create(:delivery_partner, partnerships: [partnership1, partnership2, partnership3]) }

  let(:collection) { DeliveryPartners::InductionRecordsQuery.new(delivery_partner:).induction_records }
  let(:params) { {} }
  let(:training_record_states) { DetermineTrainingRecordState.call(induction_records: collection) }

  let(:instance) { described_class.new(collection:, params:, training_record_states:) }

  subject { instance.scope.to_a }

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

    context "with academic_year not present in the options" do
      let(:params) { { academic_year: excluded_start_year } }

      it { is_expected.to be_empty }
    end

    context "with academic_year present in the options" do
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

  describe "#role_options" do
    subject(:options) { instance.role_options }

    it { expect(options.map(&:id)).to eq(["", "ect", "mentor"]) }
    it { expect(options.map(&:name)).to eq(["", "Early career teacher", "Mentor"]) }
  end

  describe "#academic_year_options" do
    before { expect(Cohort.where(start_year: excluded_start_year)).to be_exists }

    subject(:options) { instance.academic_year_options }

    let(:expected_values) { [""] + Cohort.order(:start_year).pluck(:start_year).excluding(excluded_start_year) }

    it { expect(options.map(&:id)).to eq(expected_values) }
    it { expect(options.map(&:name)).to eq(expected_values) }
  end

  describe "#status_options" do
    subject(:options) { instance.status_options }

    let(:expected_values) { I18n.t("status_tags.delivery_partner_participant_status").values.uniq }

    it { expect(options.map(&:id)).to eq([""] + expected_values.pluck(:id)) }
    it { expect(options.map(&:name)).to eq([""] + expected_values.pluck(:label)) }
  end
end

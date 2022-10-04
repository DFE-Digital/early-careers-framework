# frozen_string_literal: true

RSpec.describe Incentives::UpdateSchoolParticipants do
  describe "#call" do
    let(:school) { create(:school) }
    let(:school_cohort_21) { create :school_cohort, :fip, cohort: create(:cohort, start_year: 2021), school: }
    let(:school_cohort_22) { create :school_cohort, :fip, cohort: create(:cohort, start_year: 2022), school: }
    let(:induction_programme_21) { create(:induction_programme, :fip, school_cohort: school_cohort_21) }
    let(:induction_programme_22) { create(:induction_programme, :fip, school_cohort: school_cohort_22) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort: school_cohort_21) }
    let(:inactive_ect_profile) { create(:ect_participant_profile, school_cohort: school_cohort_22) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort: school_cohort_22) }
    let(:leaving_mentor_profile) { create(:mentor_participant_profile, school_cohort: school_cohort_21) }
    let!(:schedule) { create(:ecf_schedule, cohort: school_cohort_22.cohort) }

    let!(:ect_induction_record) do
      Induction::Enrol.call(induction_programme: induction_programme_21, participant_profile: ect_profile, start_date: 6.months.ago)
    end

    let!(:inactive_ect_induction_record) do
      Induction::Enrol.call(induction_programme: induction_programme_22, participant_profile: inactive_ect_profile, start_date: 6.months.ago).tap { |induction_record| induction_record.withdrawing!(1.month.ago) }
    end

    let!(:mentor_induction_record) do
      Induction::Enrol.call(induction_programme: induction_programme_22, participant_profile: mentor_profile, start_date: 6.months.ago)
    end

    let!(:leaving_mentor_induction_record) do
      Induction::Enrol.call(induction_programme: induction_programme_21, participant_profile: leaving_mentor_profile, start_date: 6.months.ago).tap { |induction_record| induction_record.leaving!(1.month.ago) }
    end

    subject(:service) { described_class }

    before do
      create(:pupil_premium, :uplift, school:, start_year: 2021)
      create(:pupil_premium, :sparse, school:, start_year: 2022)
      service.call(school:)
      ect_profile.reload
      mentor_profile.reload
      inactive_ect_profile.reload
      leaving_mentor_profile.reload
    end

    it "updates the incentives for all active participants in any cohort at the school" do
      expect(ect_profile).to be_pupil_premium_uplift
      expect(ect_profile).not_to be_sparsity_uplift
      expect(mentor_profile).not_to be_pupil_premium_uplift
      expect(mentor_profile).to be_sparsity_uplift
    end

    it "does not change incentives for non-active participants at the school" do
      expect(inactive_ect_profile).not_to be_pupil_premium_uplift
      expect(inactive_ect_profile).not_to be_sparsity_uplift
      expect(leaving_mentor_profile).not_to be_pupil_premium_uplift
      expect(leaving_mentor_profile).not_to be_sparsity_uplift
    end
  end
end

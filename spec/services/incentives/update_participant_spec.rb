# frozen_string_literal: true

RSpec.describe Incentives::UpdateParticipant do
  describe "#call" do
    let(:cohort) { Cohort.current || create(:cohort, :current) }
    let(:school_cohort) { create :school_cohort, :fip, cohort:}
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme:, participant_profile: ect_profile, start_date: 6.months.ago) }

    subject(:service) { described_class }

    it "updates the pupil premium incentives for participant based upon the given cohort" do
      create(:pupil_premium, :uplift, school: school_cohort.school)
      service.call(school_cohort:, participant_profile: ect_profile)
      expect(ect_profile).to be_pupil_premium_uplift
      expect(ect_profile).not_to be_sparsity_uplift
    end

    it "updates the sparsity incentives for participant based upon the given cohort" do
      create(:pupil_premium, :sparse, school: school_cohort.school)
      service.call(school_cohort:, participant_profile: ect_profile)
      expect(ect_profile).not_to be_pupil_premium_uplift
      expect(ect_profile).to be_sparsity_uplift
    end
  end
end

# frozen_string_literal: true

RSpec.describe Induction::AmendParticipantsCohort do
  describe "#call" do
    let!(:cohort_21) { create(:cohort, start_year: 2021) }
    let!(:cohort_22) { create(:cohort, start_year: 2022) }
    let!(:schedule_22) { create(:ecf_schedule, cohort: cohort_22) }
    let!(:school_cohort_21) { create(:school_cohort, :fip, cohort: cohort_21) }
    let!(:school_cohort_22) { create(:school_cohort, :fip, school: school_cohort_21.school, cohort: cohort_22) }
    let!(:successful_participant) { create(:ect_participant_profile, school_cohort: school_cohort_21) }
    let!(:failed_participant) { create(:ect_participant_profile, school_cohort: school_cohort_21) }
    let!(:emails) { [successful_participant.user.email, failed_participant.user.email] }

    subject(:service) do
      described_class.new(*emails, source_cohort_start_year: 2021, target_cohort_start_year: 2022)
    end

    before do
      Induction::SetCohortInductionProgramme.call(school_cohort: school_cohort_21,
                                                  programme_choice: school_cohort_21.induction_programme_choice)
      Induction::SetCohortInductionProgramme.call(school_cohort: school_cohort_22,
                                                  programme_choice: school_cohort_22.induction_programme_choice)
      Induction::Enrol.call(participant_profile: successful_participant,
                            induction_programme: school_cohort_21.default_induction_programme)
    end

    it "returns a list of successfully processed emails" do
      expect(service.call[:success]).to match_array([successful_participant.user.email])
    end

    it "returns a hash of emails failing and their error message" do
      expect(service.call[:fail]).to match(failed_participant.user.email => {
        induction_record: "The participant is not enrolled on the cohort starting on 2021",
      })
    end
  end
end

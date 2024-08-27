# frozen_string_literal: true

require "rails_helper"
require "tasks/valid_test_data_generator/completed_mentor_generator"

RSpec.describe ValidTestDataGenerator::CompletedMentorGenerator do
  let(:cohort) { create(:cohort, :current) }
  let(:lead_provider) { create(:lead_provider, :with_delivery_partner) }
  let(:school) { create(:school) }
  let!(:partnership) { create(:partnership, cohort:, lead_provider:) }
  let!(:school_cohort) { create(:school_cohort, school:, cohort:, induction_programme_choice: "full_induction_programme") }
  let!(:schedule_sep) { create(:ecf_schedule, schedule_identifier: "ecf-standard-september") }
  let!(:schedule_jan) { create(:ecf_schedule, schedule_identifier: "ecf-standard-january") }
  let!(:statement) { create(:ecf_statement, :next_output_fee, cpd_lead_provider: lead_provider.cpd_lead_provider, cohort:) }

  subject { described_class.new(name: lead_provider.name, cohort:) }

  describe "#call" do
    it "creates 10 mentors" do
      subject.call(total_completed_mentors: 10)

      expect(ParticipantProfile::Mentor.count).to eq(10)
    end

    it "creates participant profiles for the given cohort" do
      subject.call(total_completed_mentors: 1)

      expect(ParticipantProfile::ECF.includes(:school_cohort).pluck("school_cohorts.cohort_id")).to all(eq(cohort.id))
    end

    it "creates participant profiles for the given lead provider" do
      expect {
        subject.call(total_completed_mentors: 1)
      }.to(change(lead_provider.ecf_participant_profiles, :count))
    end
  end
end

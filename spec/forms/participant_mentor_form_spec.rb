# frozen_string_literal: true

RSpec.describe ParticipantMentorForm, type: :model do
  describe "#available_mentors" do
    let(:school_cohort) { create(:school_cohort) }
    let(:school) { school_cohort.school }

    subject { described_class.new(school_id: school.id, cohort_id: school_cohort.cohort_id) }

    it "does not include withdrawn mentors" do
      withdrawn_mentor = create(:participant_profile, :mentor, school_cohort: school_cohort, status: "withdrawn").user

      expect(subject.available_mentors).not_to include(withdrawn_mentor)
    end

    it "includes active mentors" do
      withdrawn_mentor = create(:participant_profile, :mentor, school_cohort: school_cohort).user

      expect(subject.available_mentors).to include(withdrawn_mentor)
    end
  end
end

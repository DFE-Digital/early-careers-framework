# frozen_string_literal: true

RSpec.describe ParticipantMentorForm, type: :model do
  describe "#available_mentors" do
    let(:school_cohort) { create(:school_cohort) }
    let(:school) { school_cohort.school }

    subject { described_class.new(school_id: school.id, cohort_id: school_cohort.cohort_id) }

    it "does not include permanently_inactive mentors" do
      permanently_inactive = create(:participant_profile, :mentor, :permanently_inactive, school_cohort: school_cohort).user

      expect(subject.available_mentors).not_to include(permanently_inactive)
    end

    it "includes active mentors" do
      permanently_inactive_mentor = create(:participant_profile, :mentor, school_cohort: school_cohort).user

      expect(subject.available_mentors).to include(permanently_inactive_mentor)
    end
  end
end

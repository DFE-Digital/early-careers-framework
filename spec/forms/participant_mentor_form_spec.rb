# frozen_string_literal: true

RSpec.describe ParticipantMentorForm, type: :model do
  describe "#available_mentors" do
    let(:school_cohort) { create(:school_cohort) }
    let(:school) { school_cohort.school }

    subject { described_class.new(school_id: school.id, cohort_id: school_cohort.cohort_id) }

    it "does not include mentors with withdrawn records" do
      withdrawn_mentor_record = create(:mentor_participant_profile, :withdrawn_record, school_cohort: school_cohort).user

      expect(subject.available_mentors).not_to include(withdrawn_mentor_record)
    end

    it "includes active mentors" do
      active_mentor_record = create(:mentor_participant_profile, school_cohort: school_cohort).user

      expect(subject.available_mentors).to include(active_mentor_record)
    end
  end
end

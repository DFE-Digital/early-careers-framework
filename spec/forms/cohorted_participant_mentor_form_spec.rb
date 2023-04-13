# frozen_string_literal: true

RSpec.describe ParticipantMentorForm, :with_default_schedules, type: :model do
  describe "#available_mentors" do
    let(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
    let(:school_cohort) { create(:school_cohort, cohort: cohort_2021) }
    let(:school) { school_cohort.school }
    let(:cohort_2022) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }
    let(:school_cohort_2) { create(:school_cohort, school:, cohort: cohort_2022) }

    subject { described_class.new(school_id: school.id) }

    before do
      create(:ecf_schedule, cohort: cohort_2022)
    end

    it "does not include mentors with withdrawn records" do
      withdrawn_mentor_record = create(:mentor, :withdrawn_record, school_cohort:).user

      expect(subject.available_mentors).not_to include(withdrawn_mentor_record)
    end

    it "includes active mentors" do
      active_mentor_record = create(:mentor, school_cohort:).user

      expect(subject.available_mentors).to include(active_mentor_record)
    end

    context "when there are mentors in the school mentor pool" do
      let(:mentor_profile) { create(:mentor, school_cohort:) }
      let(:mentor_profile_2) { create(:mentor, school_cohort: school_cohort_2) }

      before do
        Mentors::AddToSchool.call(school:, mentor_profile:)
        Mentors::AddToSchool.call(school:, mentor_profile: mentor_profile_2)
      end

      it "includes to mentors in the pool" do
        expect(subject.available_mentors).to match_array [mentor_profile.user, mentor_profile_2.user]
      end
    end

    context "when there are no mentors in the school mentor pool" do
      it "does not return any mentors" do
        expect(subject.available_mentors).to be_empty
      end
    end
  end
end

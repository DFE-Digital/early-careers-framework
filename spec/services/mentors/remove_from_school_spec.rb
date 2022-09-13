# frozen_string_literal: true

RSpec.describe Mentors::RemoveFromSchool do
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, cohort:) }
  let(:school) { school_cohort.school }
  let(:induction_programme) { school_cohort.default_induction_programme }
  let(:remove_on_date) { nil }
  let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
  let!(:mentee_profile) { create(:ect_participant_profile, school_cohort:) }

  before do
    Mentors::AddToSchool.call(mentor_profile:, school:)
    Induction::Enrol.call(participant_profile: mentee_profile, induction_programme:, mentor_profile:, start_date: 9.months.ago)
    described_class.call(mentor_profile:, school:, remove_on_date:)
  end

  it "removes the mentor from the school's mentor pool" do
    expect(school.mentor_profiles).not_to include mentor_profile
  end

  it "removes the mentor from their mentees" do
    expect(mentee_profile.current_induction_record.mentor_profile).to be_blank
  end

  context "when a future remove_on_date is specified" do
    let(:remove_on_date) { 1.week.from_now.to_date }

    it "does not remove the mentor from the school's mentor pool" do
      expect(school.mentor_profiles).to include mentor_profile
    end

    it "does not remove the mentor from their mentees" do
      expect(mentee_profile.current_induction_record.mentor_profile).to eq mentor_profile
    end

    it "stores the remove_on_date" do
      expect(school.school_mentors.first.remove_from_school_on).to eq remove_on_date
    end
  end
end

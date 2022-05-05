# frozen_string_literal: true

RSpec.describe Mentors::RemoveFromSchool do
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:school_cohort) { create(:school_cohort, cohort: cohort) }
  let(:school) { school_cohort.school }
  let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort: school_cohort) }

  before do
    Mentors::AddToSchool.call(mentor_profile: mentor_profile, school: school)
  end

  it "removes the school mentor record" do
    expect {
      described_class.call(
        mentor_profile: mentor_profile,
        school: school,
      )
    }.to change { SchoolMentor.count }.by(-1)
  end

  it "removes the mentor from the school's mentor pool" do
    described_class.call(
      mentor_profile: mentor_profile,
      school: school,
    )

    expect(school.mentor_profiles).not_to include mentor_profile
  end
end

# frozen_string_literal: true

RSpec.describe Mentors::AddToSchool do
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:school_cohort) { create(:school_cohort, cohort: cohort) }
  let(:school) { school_cohort.school }
  let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort: school_cohort) }

  it "creates a school mentor record" do
    expect {
      described_class.call(
        mentor_profile: mentor_profile,
        school: school,
      )
    }.to change { SchoolMentor.count }.by(1)
  end

  it "adds the mentor to the school's mentor pool" do
    described_class.call(
      mentor_profile: mentor_profile,
      school: school,
    )

    expect(school.mentor_profiles).to include mentor_profile
  end

  context "when an unused email is supplied" do
    let(:email) { "ted.mentor@digital.example.com" }

    it "adds an identity record" do
      expect {
        described_class.call(
          mentor_profile: mentor_profile,
          school: school,
          preferred_email: email,
        )
      }.to change { ParticipantIdentity.count }.by(1)
    end

    it "sets the preferred identity on the school mentor" do
      described_class.call(
        mentor_profile: mentor_profile,
        school: school,
        preferred_email: email,
      )
      expect(school.school_mentors.first.preferred_identity.email).to eq email
    end
  end
end

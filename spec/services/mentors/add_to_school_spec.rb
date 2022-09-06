# frozen_string_literal: true

RSpec.describe Mentors::AddToSchool, :with_default_schedules do
  let(:school_cohort)  { create(:school_cohort, cohort: Cohort.current) }
  let(:school)         { school_cohort.school }
  let(:mentor_profile) { create(:mentor, school_cohort:) }

  it "creates a school mentor record" do
    expect { mentor_profile }.to change { SchoolMentor.count }.by(1)
  end

  it "adds the mentor to the school's mentor pool" do
    mentor_profile

    expect(school.mentor_profiles).to include mentor_profile
  end

  context "when an unused email is supplied" do
    let(:email) { "ted.mentor@digital.example.com" }
    let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }

    it "adds an identity record" do
      expect {
        described_class.call(
          mentor_profile:,
          school:,
          preferred_email: email,
        )
      }.to change { ParticipantIdentity.count }.by(1)
    end

    it "sets the preferred identity on the school mentor" do
      described_class.call(
        mentor_profile:,
        school:,
        preferred_email: email,
      )
      expect(school.school_mentors.first.preferred_identity.email).to eq email
    end
  end
end

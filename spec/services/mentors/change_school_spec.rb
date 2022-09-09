# frozen_string_literal: true

RSpec.describe Mentors::ChangeSchool do
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, cohort:) }
  let(:old_school) { school_cohort.school }
  let(:new_school) { create(:school) }
  let(:induction_programme) { school_cohort.default_induction_programme }
  let(:preferred_email) { nil }
  let(:remove_on_date) { nil }
  let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
  let!(:mentee_profile) { create(:ect_participant_profile, school_cohort:) }

  before do
    Mentors::AddToSchool.call(mentor_profile:, school: old_school)
    Induction::Enrol.call(participant_profile: mentee_profile, induction_programme:, mentor_profile:, start_date: 9.months.ago)
    described_class.call(mentor_profile:, from_school: old_school, to_school: new_school, preferred_email:, remove_on_date:)
  end

  it "adds the mentor to the mentor pool at the new school" do
    expect(new_school.mentor_profiles).to include mentor_profile
  end

  it "removes the mentor from the mentor pool at the old school" do
    expect(new_school.mentor_profiles).to include mentor_profile
  end

  it "removes the mentor from their mentees at the old school" do
    expect(mentee_profile.current_induction_record.mentor_profile).to be_blank
  end

  context "when a preferred email is supplied" do
    let(:preferred_email) { "micky.mentor@example.com" }

    it "sets the preferred email on the new school mentor record" do
      expect(new_school.school_mentors.first.preferred_identity.email).to eq preferred_email
    end
  end

  context "when a future remove_on_date is specified" do
    let(:remove_on_date) { 1.week.from_now.to_date }

    it "adds the mentor to the mentor pool at the new school" do
      expect(new_school.mentor_profiles).to include mentor_profile
    end

    it "does not remove the mentor from the old school's mentor pool" do
      expect(old_school.mentor_profiles).to include mentor_profile
    end

    it "does not remove the mentor from their mentees at the old school" do
      expect(mentee_profile.current_induction_record.mentor_profile).to eq mentor_profile
    end

    it "stores the remove_on_date" do
      expect(old_school.school_mentors.first.remove_from_school_on).to eq remove_on_date
    end
  end
end

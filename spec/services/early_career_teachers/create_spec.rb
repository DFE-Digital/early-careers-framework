# frozen_string_literal: true

RSpec.describe EarlyCareerTeachers::Create do
  let(:user) { create :user }
  let(:school) { create :school }
  let(:pupil_premium_school) { create :school, :pupil_premium_uplift }
  let(:sparsity_school) { create :school, :sparsity_uplift }
  let(:uplift_school) { create :school, :sparsity_uplift, :pupil_premium_uplift }
  let(:cohort) { create :cohort, :current }
  let(:mentor_profile) { create :mentor_profile }

  it "creates an Early Career Teacher Profile record" do
    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_id: school.id,
        cohort_id: cohort.id,
        mentor_profile_id: mentor_profile.id,
      )
    }.to change { ParticipantProfile::ECT.count }.by(1)
  end

  it "sets the correct mentor profile" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: school.id, cohort_id: cohort.id, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.mentor_profile).to eq(mentor_profile)
  end

  it "has no uplift if the school has not uplift set" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: school.id, cohort_id: cohort.id, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only pupil_premium_uplift set when the school has only pupil_premium_uplift set" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: pupil_premium_school.id, cohort_id: cohort.id, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only sparsity_uplift set when the school has only sparsity_uplift set" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: sparsity_school.id, cohort_id: cohort.id, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "has both sparsity_uplift and pupil_premium_uplift set when the school has both pupil_premium_uplift and sparsity_uplift set" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: uplift_school.id, cohort_id: cohort.id, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(true)
  end
end

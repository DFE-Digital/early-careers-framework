# frozen_string_literal: true

RSpec.describe Mentors::Create do
  let(:user) { create :user }
  let(:school) { create :school }
  let(:pupil_premium_school) { create :school, :pupil_premium_uplift }
  let(:sparsity_school) { create :school, :sparsity_uplift }
  let(:uplift_school) { create :school, :sparsity_uplift, :pupil_premium_uplift }
  let(:cohort) { create :cohort, :current }

  it "creates a Mentor record" do
    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_id: school.id,
        cohort_id: cohort.id,
      )
    }.to change { ParticipantProfile::Mentor.count }.by(1)

    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_id: school.id,
        cohort_id: cohort.id,
        mentor_id: "random discardable",
      )
    }.to change { ParticipantProfile::Mentor.count }.by(1)
  end

  it "has no uplift if the school has not uplift set" do
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: school.id, cohort_id: cohort.id)
    expect(mentor_profile.pupil_premium_uplift).to be(false)
    expect(mentor_profile.sparsity_uplift).to be(false)
  end

  it "has only pupil_premium_uplift set when the school has only pupil_premium_uplift set" do
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: pupil_premium_school.id, cohort_id: cohort.id)
    expect(mentor_profile.pupil_premium_uplift).to be(true)
    expect(mentor_profile.sparsity_uplift).to be(false)
  end

  it "has only sparsity_uplift set when the school has only sparsity_uplift set" do
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: sparsity_school.id, cohort_id: cohort.id)
    expect(mentor_profile.pupil_premium_uplift).to be(false)
    expect(mentor_profile.sparsity_uplift).to be(true)
  end

  it "has both sparsity_uplift and pupil_premium_uplift set when the school has both pupil_premium_uplift and sparsity_uplift set" do
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_id: uplift_school.id, cohort_id: cohort.id)
    expect(mentor_profile.pupil_premium_uplift).to be(true)
    expect(mentor_profile.sparsity_uplift).to be(true)
  end
end

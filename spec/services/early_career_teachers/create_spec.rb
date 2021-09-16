# frozen_string_literal: true

RSpec.describe EarlyCareerTeachers::Create do
  let!(:user) { create :user }
  let(:school_cohort) { create :school_cohort }
  let(:pupil_premium_school) { create :school, :pupil_premium_uplift }
  let(:sparsity_school) { create :school, :sparsity_uplift }
  let(:uplift_school) { create :school, :sparsity_uplift, :pupil_premium_uplift }
  let!(:mentor_profile) { create :participant_profile, :mentor }
  let!(:npq_participant) { create(:participant_profile, :npq).teacher_profile.user }

  it "creates an Early Career Teacher Profile record" do
    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_cohort: school_cohort,
        mentor_profile_id: mentor_profile.id,
      )
    }.to change { ParticipantProfile::ECT.count }.by(1)
     .and not_change { User.count }
     .and change { TeacherProfile.count }.by(1)
  end

  it "uses the existing teacher profile record" do
    expect {
      described_class.call(
        email: npq_participant.email,
        full_name: npq_participant.full_name,
        school_cohort: school_cohort,
      )
    }.to change { ParticipantProfile::ECT.count }.by(1)
     .and not_change { User.count }
     .and not_change { TeacherProfile.count }
  end

  it "creates a new user and teacher profile" do
    expect {
      described_class.call(
        email: Faker::Internet.email,
        full_name: Faker::Name.name,
        school_cohort: school_cohort,
      )
    }.to change { ParticipantProfile::ECT.count }.by(1)
    .and change { User.count }.by(1)
    .and change { TeacherProfile.count }.by(1)
  end

  it "updates the users name" do
    expect {
      described_class.call(
        email: user.email,
        full_name: Faker::Name.name,
        school_cohort: school_cohort,
      )
    }.to change { user.reload.full_name }
  end

  it "schedules participant_added email" do
    profile = described_class.call(
      email: user.email,
      full_name: Faker::Name.name,
      school_cohort: school_cohort,
    )

    expect(ParticipantMailer).to delay_email_delivery_of(:participant_added).with(participant_profile: profile)
  end

  it "scheduled reminder email job" do
    allow(ParticipantDetailsReminderJob).to receive(:schedule)

    profile = described_class.call(
      email: user.email,
      full_name: Faker::Name.name,
      school_cohort: school_cohort,
    )

    expect(ParticipantDetailsReminderJob).to have_received(:schedule).with(profile)
  end

  context "when the user has an active participant profile" do
    before do
      create(:participant_profile, teacher_profile: create(:teacher_profile, user: user))
    end

    it "does not update the users name" do
      expect {
        described_class.call(
          email: user.email,
          full_name: Faker::Name.name,
          school_cohort: school_cohort,
        )
      }.not_to change { user.reload.full_name }
    end
  end

  it "sets the correct mentor profile" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.mentor_profile).to eq(mentor_profile)
  end

  it "has no uplift if the school has not uplift set" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only pupil_premium_uplift set when the school has only pupil_premium_uplift set" do
    school_cohort.update!(school: pupil_premium_school)
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only sparsity_uplift set when the school has only sparsity_uplift set" do
    school_cohort.update!(school: sparsity_school)
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "has both sparsity_uplift and pupil_premium_uplift set when the school has both pupil_premium_uplift and sparsity_uplift set" do
    school_cohort.update!(school: uplift_school)
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(true)
  end
end

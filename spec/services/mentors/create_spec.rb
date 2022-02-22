# frozen_string_literal: true

RSpec.describe Mentors::Create, :with_default_schedules do
  let!(:user) { create :user }
  let(:school_cohort) { create :school_cohort }
  let(:pupil_premium_school) { create :school, :pupil_premium_uplift }
  let(:sparsity_school) { create :school, :sparsity_uplift }
  let(:uplift_school) { create :school, :sparsity_uplift, :pupil_premium_uplift }
  let!(:npq_participant) { create(:npq_participant_profile).teacher_profile.user }

  it "creates a Mentor record" do
    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_cohort: school_cohort,
      )
    }.to change { ParticipantProfile::Mentor.count }.by(1)
     .and not_change { User.count }
  end

  it "uses the existing teacher profile record" do
    expect {
      described_class.call(
        email: npq_participant.email,
        full_name: npq_participant.full_name,
        school_cohort: school_cohort,
        mentor_id: "random discardable",
      )
    }.to change { ParticipantProfile::Mentor.count }.by(1)
     .and not_change { User.count }
     .and not_change { TeacherProfile.count }
  end

  it "ignores mentor id" do
    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_cohort: school_cohort,
        mentor_id: "random discardable",
      )
    }.to change { ParticipantProfile::Mentor.count }.by(1)
  end

  it "creates a new user and teacher profile" do
    expect {
      described_class.call(
        email: Faker::Internet.email,
        full_name: Faker::Name.name,
        school_cohort: school_cohort,
      )
    }.to change { ParticipantProfile::Mentor.count }.by(1)
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

  context "when default induction programme is set on the school cohort" do
    it "creates an induction record" do
      induction_programme = create(:induction_programme, :fip, school_cohort: school_cohort)
      school_cohort.update!(default_induction_programme: induction_programme)

      expect {
        described_class.call(
          email: user.email,
          full_name: user.full_name,
          school_cohort: school_cohort,
        )
      }.to change { InductionRecord.count }.by(1)
    end
  end

  context "when there is no default induction programme set" do
    it "does not create an induction record" do
      expect {
        described_class.call(
          email: user.email,
          full_name: user.full_name,
          school_cohort: school_cohort,
        )
      }.not_to change { InductionRecord.count }
    end
  end

  it "schedules participant_added email" do
    expect {
      described_class.call(
        email: user.email,
        full_name: Faker::Name.name,
        school_cohort: school_cohort,
      )
    }.to have_enqueued_mail(ParticipantMailer, :participant_added)
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
      create(:ecf_participant_profile, teacher_profile: create(:teacher_profile, user: user))
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

  it "has no uplift if the school has not uplift set" do
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort)
    expect(mentor_profile.pupil_premium_uplift).to be(false)
    expect(mentor_profile.sparsity_uplift).to be(false)
  end

  it "has only pupil_premium_uplift set when the school has only pupil_premium_uplift set" do
    school_cohort.update!(school: pupil_premium_school)
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort)
    expect(mentor_profile.pupil_premium_uplift).to be(true)
    expect(mentor_profile.sparsity_uplift).to be(false)
  end

  it "has only sparsity_uplift set when the school has only sparsity_uplift set" do
    school_cohort.update!(school: sparsity_school)
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort)
    expect(mentor_profile.pupil_premium_uplift).to be(false)
    expect(mentor_profile.sparsity_uplift).to be(true)
  end

  it "has both sparsity_uplift and pupil_premium_uplift set when the school has both pupil_premium_uplift and sparsity_uplift set" do
    school_cohort.update!(school: uplift_school)
    mentor_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort: school_cohort)
    expect(mentor_profile.pupil_premium_uplift).to be(true)
    expect(mentor_profile.sparsity_uplift).to be(true)
  end

  it "records the profile for analytics" do
    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_cohort: school_cohort,
      )
    }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob)
  end
end

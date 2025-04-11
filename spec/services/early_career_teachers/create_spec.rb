# frozen_string_literal: true

RSpec.describe ::EarlyCareerTeachers::Create do
  let!(:user) { create :user }
  let(:school_cohort) { create :school_cohort }
  let(:start_year) { school_cohort.cohort.start_year }
  let(:pupil_premium_school) { create :seed_school, :with_pupil_premium_uplift, start_year: }
  let(:sparsity_school) { create :seed_school, :with_sparsity_uplift, start_year: }
  let(:uplift_school) { create :seed_school, :with_uplifts, start_year: }
  let!(:mentor_profile) { create :mentor_participant_profile }

  it "creates an Early Career Teacher Profile record" do
    expect {
      described_class.call(
        email: user.email,
        full_name: user.full_name,
        school_cohort:,
        mentor_profile_id: mentor_profile.id,
      )
    }.to change { ParticipantProfile::ECT.count }
           .by(1)
           .and not_change { User.count }
                  .and change { TeacherProfile.count }.by(1)
  end

  it "creates a new user and teacher profile" do
    expect {
      described_class.call(
        email: Faker::Internet.email,
        full_name: Faker::Name.name,
        school_cohort:,
      )
    }.to change { ParticipantProfile::ECT.count }
           .by(1)
           .and change { User.count }.by(1)
                                     .and change { TeacherProfile.count }.by(1)
  end

  it "updates the users name" do
    expect {
      described_class.call(
        email: user.email,
        full_name: Faker::Name.name,
        school_cohort:,
      )
    }.to change { user.reload.full_name }
  end

  context "when default induction programme is set on the school cohort" do
    it "creates an induction record" do
      induction_programme = create(:induction_programme, :fip, school_cohort:)
      school_cohort.update!(default_induction_programme: induction_programme)

      expect {
        described_class.call(
          email: user.email,
          full_name: user.full_name,
          school_cohort:,
          mentor_profile_id: mentor_profile.id,
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
          school_cohort:,
          mentor_profile_id: mentor_profile.id,
        )
      }.not_to change { InductionRecord.count }
    end
  end

  context "when the user has an active participant profile" do
    context "when the profile is attached to teacher_profile" do
      before do
        create(:ect_participant_profile, teacher_profile: create(:teacher_profile, user:))
      end

      it "raises an error" do
        expect {
          described_class.call(
            email: user.email,
            full_name: Faker::Name.name,
            school_cohort:,
          )
        }.to raise_error(described_class::ParticipantProfileExistsError)
      end
    end

    context "when the profile is attached to teacher_profile" do
      before do
        create(:ect_participant_profile).update!(participant_identity: create(:participant_identity, user:))
      end

      it "raises an error" do
        expect {
          described_class.call(
            email: user.email,
            full_name: Faker::Name.name,
            school_cohort:,
          )
        }.to raise_error(described_class::ParticipantProfileExistsError)
      end
    end
  end

  context "when the mentor is in a frozen cohort and the ECT is not" do
    let(:frozen_cohort) { Cohort.find_by_start_year(2021) || create(:cohort, start_year: 2021) }
    let(:ect_school_cohort) do
      NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort: Cohort.current).build.with_programme.school_cohort
    end
    let(:mentor_school_cohort) do
      NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort: frozen_cohort).build.with_programme.school_cohort
    end

    let!(:mentor_profile) do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
        .new(school_cohort: mentor_school_cohort)
        .build
        .with_induction_record(induction_programme: mentor_school_cohort.default_induction_programme)
        .participant_profile
    end

    before do
      frozen_cohort.update!(payments_frozen_at: 1.month.ago)
    end

    it "moves the mentor to the currently active registration cohort" do
      expect { described_class.call(email: user.email, full_name: user.full_name, school_cohort: ect_school_cohort, mentor_profile_id: mentor_profile.id) }
        .to change { mentor_profile.reload.schedule.cohort.start_year }.from(2021).to(Cohort.active_registration_cohort.start_year)
    end
  end

  it "sets the correct mentor profile" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.mentor_profile).to eq(mentor_profile)
  end

  it "has no uplift if the school has not uplift set" do
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only pupil_premium_uplift set when the school has only pupil_premium_uplift set" do
    school_cohort.update!(school: pupil_premium_school)
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only sparsity_uplift set when the school has only sparsity_uplift set" do
    school_cohort.update!(school: sparsity_school)
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "has both sparsity_uplift and pupil_premium_uplift set when the school has both pupil_premium_uplift and sparsity_uplift set" do
    school_cohort.update!(school: uplift_school)
    participant_profile = described_class.call(email: user.email, full_name: user.full_name, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "records the profile for analytics" do
    described_class.call(
      email: user.email,
      full_name: user.full_name,
      school_cohort:,
      mentor_profile_id: mentor_profile.id,
    )

    created_participant = ParticipantProfile.order(:created_at).last
    expect(Analytics::UpsertECFParticipantProfileJob).to have_been_enqueued.with(participant_profile_id: created_participant.id)
  end
end

# frozen_string_literal: true

RSpec.describe EarlyCareerTeachers::Reactivate do
  let!(:user) { create :user }
  let(:trn) { user.teacher_profile.trn }
  let!(:school) { create(:school, name: "Fip School") }
  let!(:cohort) { Cohort.current || create(:cohort, start_year: 2022) }
  let(:start_year) { school_cohort.cohort.start_year }
  let(:pupil_premium_school) { create :seed_school, :with_pupil_premium_uplift, start_year: }
  let(:sparsity_school) { create :seed_school, :with_sparsity_uplift, start_year: }
  let(:uplift_school) { create :seed_school, :with_uplifts, start_year: }
  let!(:mentor_profile) { create :mentor_participant_profile }

  let!(:appropriate_body) { create :appropriate_body_national_organisation }
  let!(:school_cohort) { create(:school_cohort, school:, cohort:, induction_programme_choice: "full_induction_programme", appropriate_body:) }
  let(:lead_provider) { create(:lead_provider, name: "Big Provider Ltd") }
  let(:delivery_partner) { create(:delivery_partner, name: "Amazing Delivery Team") }
  let!(:partnership) do
    create(:partnership,
           school:,
           lead_provider:,
           delivery_partner:,
           cohort:,
           challenge_deadline: 2.weeks.ago)
  end
  let!(:induction_programme) do
    induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
    school_cohort.update! default_induction_programme: induction_programme
    induction_programme
  end
  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end
  let!(:induction_coordinator) do
    induction_coordinator_profile = create(:induction_coordinator_profile, schools: [school_cohort.school], user:)
    PrivacyPolicy.current.accept!(user)
    induction_coordinator_profile
  end
  let!(:schedule) { create(:ecf_schedule) }

  let(:creation_date_for_withdrawn_record) { Date.new(cohort.start_year - 1, 1, 1) }
  let!(:participant_profile) { add_and_remove_participant_from_school_cohort(school_cohort) }
  let!(:current_withdrawn_induction_record) { participant_profile.latest_induction_record }

  it "uses the existing teacher profile record" do
    expect {
      described_class.call(
        email: user.email,
        participant_profile:,
        school_cohort:,
      )
    }.to not_change { ParticipantProfile::ECT.count }
     .and not_change { User.count }
     .and not_change { TeacherProfile.count }
  end

  it "adds the ECT to the school's ECTs" do
    expect {
      described_class.call(
        email: user.email,
        participant_profile:,
        school_cohort:,
      )
    }.to change { school.reload.ecf_participant_profiles.ects.active_record.count }.by(1)
  end

  it "closes out the existing induction record" do
    frozen_time = Time.current.at_beginning_of_minute
    travel_to(frozen_time)
    expect {
      described_class.call(
        email: user.email,
        participant_profile:,
        school_cohort:,
      )
    }.to change { current_withdrawn_induction_record.reload.end_date }.from(nil).to(frozen_time)
  end

  it "reactivates the existing participant profile" do
    expect {
      described_class.call(
        email: user.email,
        participant_profile:,
        school_cohort:,
      )
    }.to change { participant_profile.reload.status }.from("withdrawn").to("active")
  end

  context "when default induction programme is set on the school cohort" do
    it "creates an induction record" do
      expect {
        described_class.call(
          email: user.email,
          participant_profile:,
          school_cohort:,
          mentor_profile_id: mentor_profile.id,
        )
      }.to change { InductionRecord.count }.by(1)
    end
  end

  context "when there is no default induction programme set" do
    before do
      school_cohort.update!(default_induction_programme: nil)
    end

    it "does not create an induction record" do
      expect {
        described_class.call(
          email: user.email,
          participant_profile:,
          school_cohort:,
          mentor_profile_id: mentor_profile.id,
        )
      }.not_to change { InductionRecord.count }
    end
  end

  it "sets the correct mentor profile" do
    described_class.call(email: user.email, participant_profile:, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.reload.mentor_profile).to eq(mentor_profile)
  end

  it "has no uplift if the school has not uplift set" do
    described_class.call(email: user.email, participant_profile:, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.reload.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only pupil_premium_uplift set when the school has only pupil_premium_uplift set" do
    school_cohort.update!(school: pupil_premium_school)
    described_class.call(email: user.email, participant_profile:, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.reload.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only sparsity_uplift set when the school has only sparsity_uplift set" do
    school_cohort.update!(school: sparsity_school)
    described_class.call(email: user.email, participant_profile:, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.reload.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "has both sparsity_uplift and pupil_premium_uplift set when the school has both pupil_premium_uplift and sparsity_uplift set" do
    school_cohort.update!(school: uplift_school)
    described_class.call(email: user.email, participant_profile:, school_cohort:, mentor_profile_id: mentor_profile.id)
    expect(participant_profile.reload.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "records the profile for analytics" do
    expect {
      described_class.call(
        email: user.email,
        participant_profile:,
        school_cohort:,
        mentor_profile_id: mentor_profile.id,
      )
    }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob)
     .with(participant_profile: instance_of(ParticipantProfile::ECT))
  end

  def add_and_remove_participant_from_school_cohort(school_cohort)
    profile = nil
    travel_to(creation_date_for_withdrawn_record) do
      profile = add_participant_to_school(full_name: user.full_name,
                                          email: user.email,
                                          appropriate_body:,
                                          school_cohort:)
      withdraw_participant(participant_profile: profile)
    end

    profile
  end

  def add_participant_to_school(full_name:, email:, appropriate_body:, school_cohort:)
    EarlyCareerTeachers::Create.call(
      full_name:,
      email:,
      school_cohort:,
      start_date: Time.current,
      appropriate_body_id: appropriate_body.id,
      induction_start_date: Time.current,
    ).tap do |participant_profile|
      participant_profile.teacher_profile.update!(trn:)
    end
  end

  def withdraw_participant(participant_profile:)
    participant_profile.withdrawn_record!
  end
end

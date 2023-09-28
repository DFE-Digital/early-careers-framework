# frozen_string_literal: true

RSpec.describe Mentors::Reactivate do
  let!(:user) { create :user }
  let(:trn) { user.teacher_profile.trn }
  let!(:cohort) { Cohort.current || create(:cohort, start_year: 2022) }
  let!(:school) { create(:school, name: "Fip School") }
  let(:pupil_premium_school) { create :school, :pupil_premium_uplift }
  let(:sparsity_school) { create :school, :sparsity_uplift }
  let(:uplift_school) { create :school, :pupil_premium_and_sparsity_uplift }

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
    school_cohort.update!(default_induction_programme: induction_programme)
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

  it "adds the mentor to the school mentors pool" do
    expect {
      described_class.call(
        email: user.email,
        participant_profile:,
        school_cohort:,
      )
    }.to change { school.mentor_profiles.active_record.count }.by(1)
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
        )
      }.not_to change { InductionRecord.count }
    end
  end

  it "has no uplift if the school has not uplift set" do
    described_class.call(email: user.email, participant_profile:, school_cohort:)
    expect(participant_profile.reload.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only pupil_premium_uplift set when the school has only pupil_premium_uplift set" do
    school_cohort.update!(school: pupil_premium_school)
    described_class.call(email: user.email, participant_profile:, school_cohort:)
    expect(participant_profile.reload.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(false)
  end

  it "has only sparsity_uplift set when the school has only sparsity_uplift set" do
    school_cohort.update!(school: sparsity_school)
    described_class.call(email: user.email, participant_profile:, school_cohort:)
    expect(participant_profile.reload.pupil_premium_uplift).to be(false)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "has both sparsity_uplift and pupil_premium_uplift set when the school has both pupil_premium_uplift and sparsity_uplift set" do
    school_cohort.update!(school: uplift_school)
    described_class.call(email: user.email, participant_profile:, school_cohort:)
    expect(participant_profile.reload.pupil_premium_uplift).to be(true)
    expect(participant_profile.sparsity_uplift).to be(true)
  end

  it "records the profile for analytics" do
    expect {
      described_class.call(
        email: user.email,
        participant_profile:,
        school_cohort:,
      )
    }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob)
  end

  def add_and_remove_participant_from_school_cohort(school_cohort)
    profile = nil
    travel_to(creation_date_for_withdrawn_record) do
      profile = add_participant_to_school(full_name: user.full_name,
                                          email: user.email,
                                          school_cohort:)
      withdraw_participant(participant_profile: profile)
    end

    profile
  end

  def add_participant_to_school(full_name:, email:, school_cohort:)
    Mentors::Create.call(
      full_name:,
      email:,
      school_cohort:,
      start_date: Time.current,
    ).tap do |participant_profile|
      participant_profile.teacher_profile.update!(trn:)
    end
  end

  def withdraw_participant(participant_profile:)
    participant_profile.update!(status: :withdrawn)
    participant_profile.reload.latest_induction_record.withdrawing!
    participant_profile.mentee_profiles.update_all(mentor_profile_id: nil)

    participant_profile.mentee_profiles.each do |mentee_profile|
      Induction::ChangeInductionRecord.call(
        induction_record: mentee_profile.latest_induction_record,
        changes: {
          mentor_profile_id: nil,
        },
      )
    end
  end
end

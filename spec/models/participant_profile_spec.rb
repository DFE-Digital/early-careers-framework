# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile, type: :model do
  it { is_expected.to belong_to(:teacher_profile) }
  it { is_expected.to belong_to(:schedule) }
  it { is_expected.to have_one(:user).through(:teacher_profile) }
  it {
    is_expected.to define_enum_for(:status).with_values(
      active: "active",
      withdrawn: "withdrawn",
    ).with_suffix(:record).backed_by_column_of_type(:text)
  }

  it "updates the updated_at on the users" do
    freeze_time
    user = create(:user, updated_at: 2.weeks.ago)
    profile = create(:participant_profile, teacher_profile: user.create_teacher_profile)

    profile.touch
    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
  end

  describe described_class::Mentor do
    it { is_expected.to belong_to(:school_cohort) }
    it { is_expected.to have_one(:cohort).through(:school_cohort) }
    it { is_expected.to have_one(:school).through(:school_cohort) }

    it { is_expected.to belong_to(:teacher_profile) }
    it { is_expected.to have_one(:user).through(:teacher_profile) }
    it { is_expected.to belong_to(:core_induction_programme).optional }

    it { is_expected.to have_many(:mentee_profiles) }
    it { is_expected.to have_many(:mentees).through(:mentee_profiles) }
    it { is_expected.to be_versioned }
  end

  describe described_class::ECT do
    it { is_expected.to belong_to(:school_cohort) }
    it { is_expected.to have_one(:cohort).through(:school_cohort) }
    it { is_expected.to have_one(:school).through(:school_cohort) }

    it { is_expected.to belong_to(:mentor_profile).optional }
    it { is_expected.to have_one(:mentor).through(:mentor_profile) }
    it { is_expected.to belong_to(:core_induction_programme).optional }
    it { is_expected.to be_versioned }
  end

  describe described_class::NPQ do
    it { is_expected.to belong_to(:school).optional }
    it { is_expected.to be_versioned }
  end

  it "correctly shows the profile state when there are two deferred participants" do
    create(:schedule, name: "ECF September standard 2021")

    profile_one = EarlyCareerTeachers::Create.new(full_name: "Bob", email: "bob@example.com", school_cohort: create(:school_cohort)).call
    profile_two = EarlyCareerTeachers::Create.new(full_name: "Ted", email: "ted@example.com", school_cohort: create(:school_cohort)).call

    ParticipantProfileState.create!(participant_profile: profile_one, state: "deferred")
    ParticipantProfileState.create!(participant_profile: profile_two, state: "deferred")

    profile_one.reload
    profile_two.reload

    User.all.ecf_participants_endpoint_scope.each do |user|
      expect(user.teacher_profile.ecf_profile&.state).to eq("deferred")
    end
  end
end

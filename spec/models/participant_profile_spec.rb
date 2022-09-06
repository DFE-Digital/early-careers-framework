# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile, type: :model do
  it { is_expected.to belong_to(:teacher_profile) }
  it { is_expected.to belong_to(:participant_identity) }
  it { is_expected.to belong_to(:schedule) }
  it { is_expected.to have_one(:user).through(:teacher_profile) }
  it {
    is_expected.to define_enum_for(:status).with_values(
      active: "active",
      withdrawn: "withdrawn",
    ).with_suffix(:record).backed_by_column_of_type(:text)
  }

  it "updates the updated_at on the users", :with_default_schedules do
    freeze_time do
      user = create(:user, updated_at: 2.weeks.ago)
      profile = create(:ect, user:)

      profile.touch
      expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
    end
  end

  it "updates analytics when any attributes changes", :with_default_schedules do
    profile = create(:ect)
    profile.training_status = :withdrawn
    expect {
      profile.save!
    }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob).with(
      participant_profile: profile,
    )
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

    it { is_expected.to have_many(:induction_records) }
    it { is_expected.to be_versioned }
  end

  describe described_class::NPQ do
    it { is_expected.to belong_to(:school).optional }
    it { is_expected.to be_versioned }
  end

  describe "#role" do
    it "should fail with 'Not implemented'" do
      expect { subject.role }.to raise_error("Not implemented")
    end
  end
end

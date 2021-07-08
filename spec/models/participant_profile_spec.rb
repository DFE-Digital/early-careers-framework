# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile, type: :model do
  it { is_expected.to belong_to(:user) }
  it {
    is_expected.to define_enum_for(:status).with_values(
      active: "active",
      withdrawn: "withdrawn",
    ).backed_by_column_of_type(:text)
  }

  describe described_class::Mentor do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:core_induction_programme).optional }

    it { is_expected.to have_many(:mentee_profiles) }
    it { is_expected.to have_many(:mentees).through(:mentee_profiles) }
  end

  describe described_class::ECT do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:mentor_profile).optional }
    it { is_expected.to have_one(:mentor).through(:mentor_profile) }
    it { is_expected.to belong_to(:core_induction_programme).optional }
  end

  describe described_class::NPQ do
    it { is_expected.to belong_to(:school).optional }
  end
end

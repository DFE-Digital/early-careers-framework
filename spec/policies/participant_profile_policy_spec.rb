# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfilePolicy, :with_default_schedules, type: :policy do
  subject { described_class.new(user, participant_profile) }

  let(:participant_profile) { create(:ect) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }
    it { is_expected.to permit_action(:show) }

    context "NPQ" do
      let(:participant_profile) { create(:npq_participant_profile) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context "not an admin" do
    let(:user) { create(:user) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe described_class::Scope do
    subject(:result) { described_class.new(user, ParticipantProfile).resolve }

    context "for an admin user" do
      let(:all_participant_profiles) { create_list :ect, rand(2..3) }
      let(:user) { create :user, :admin }

      it { is_expected.to include(*all_participant_profiles) }
    end

    context "for an induction coordinator" do
      let(:schools) { create_list :school, rand(2..3) }
      let(:user) { create(:induction_coordinator_profile, schools:).user }
      let(:ect_profiles_for_stis_schools) { Array.new(rand(3..5)) { create :ect, school_cohort: create(:school_cohort, school: schools.sample) } }
      let(:mentor_profiles_for_stis_schools) { Array.new(rand(3..5)) { create :mentor, school_cohort: create(:school_cohort, school: schools.sample) } }
      let(:npq_profiles_for_stis_schools) { Array.new(rand(3..5)) { create :npq_participant_profile, school: schools.sample } }
      let(:other_participant_profiles) { create_list :ect, rand(2..3) }

      it { is_expected.to include(*ect_profiles_for_stis_schools) }
      it { is_expected.to include(*mentor_profiles_for_stis_schools) }
      it { is_expected.not_to include(*npq_profiles_for_stis_schools) }
      it { is_expected.not_to include(*other_participant_profiles) }
    end

    context "for a regular user" do
      let(:user) { create :user }
      let!(:participant_profiles) { create_list :ect, rand(2..3) }

      it { is_expected.to be_empty }
    end
  end
end

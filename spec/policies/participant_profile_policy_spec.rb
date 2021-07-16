# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfilePolicy, type: :policy do
  describe described_class::Scope do
    subject(:result) { described_class.new(user, ParticipantProfile).resolve }

    context "for an admin user" do
      let(:all_participant_profiles) { create_list :participant_profile, rand(2..3) }
      let(:user) { create :user, :admin }

      it { is_expected.to include(*all_participant_profiles) }
    end

    context "for an induction coordinator" do
      let(:schools) { create_list :school, rand(2..3) }
      let(:user) { create(:induction_coordinator_profile, schools: schools).user }
      let(:participant_profiles_for_stis_schools) { Array.new(rand(3..5)) { create :participant_profile, school_cohort: create(:school_cohort, school: schools.sample) } }
      let(:other_participant_profiles) { create_list :participant_profile, rand(2..3) }

      it { is_expected.to include(*participant_profiles_for_stis_schools) }
      it { is_expected.not_to include(*other_participant_profiles) }
    end

    context "for a regular user" do
      let(:user) { create :user }
      let!(:participant_profiles) { create_list :participant_profile, rand(2..3) }

      it { is_expected.to be_empty }
    end
  end
end

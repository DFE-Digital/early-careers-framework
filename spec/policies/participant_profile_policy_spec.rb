# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfilePolicy, type: :policy do
  subject { described_class.new(user, participant_profile) }

  let(:participant_profile) { create(:ect) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_actions(%i[edit_cohort update_cohort]) }

    context "NPQ" do
      let(:participant_profile) { create(:npq_participant_profile) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  context "not an admin" do
    let(:user) { create(:user) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_actions(%i[edit_cohort update_cohort]) }
  end

  context "being a super user admin" do
    let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build.with_super_user }
    let(:user) { scenario.user }

    it { is_expected.to permit_actions(%i[edit_cohort update_cohort]) }
  end

  describe described_class::Scope do
    subject(:result) { described_class.new(user, ParticipantProfile).resolve }

    context "for an admin user" do
      let(:all_participant_profiles) { create_list :ect, rand(2..3) }
      let(:user) { create :user, :admin }

      it { is_expected.to include(*all_participant_profiles) }
    end

    context "for an induction coordinator" do
      let(:induction_coordinator_profile_school) { FactoryBot.create(:seed_induction_coordinator_profiles_school, :valid) }
      let(:induction_coordinator) { induction_coordinator_profile_school.induction_coordinator_profile }
      let(:user) { induction_coordinator.user }
      let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :valid, school: induction_coordinator_profile_school.school) }
      let(:induction_programme) { FactoryBot.create(:seed_induction_programme, school_cohort:) }
      let(:induction_record) { FactoryBot.create(:seed_induction_record, :valid, induction_programme:) }

      let(:another_induction_record) { FactoryBot.create(:seed_induction_record, :valid) }

      it "includes participant profiles linked to schools the user is a SIT at" do
        expect(subject).to include(induction_record.participant_profile)
      end

      it "doesn't include participant profiles not linked to schools the user is a SIT at" do
        expect(subject).not_to include(another_induction_record.participant_profile)
      end
    end

    context "for a regular user" do
      let(:user) { create :user }
      let!(:participant_profiles) { create_list :ect, rand(2..3) }

      it { is_expected.to be_empty }
    end
  end
end

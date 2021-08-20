# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantPolicy, type: :policy do
  subject { described_class.new(acting_user, user_under_test) }

  %i[ect mentor].each do |profile_type|
    context "when the participant has #{profile_type} profile" do
      let(:profile) { create(:participant_profile, profile_type) }
      let(:user_under_test) { profile.user }

      context "being an admin" do
        let(:acting_user) { create(:user, :admin) }

        it { is_expected.to permit_new_and_create_actions }
        it { is_expected.to permit_edit_and_update_actions }
        it { is_expected.to permit_action(:destroy) }
      end

      context "being an induction coordinator" do
        context "when from the same school" do
          let(:acting_user) { create(:user, :induction_coordinator, school_ids: [profile.school.id]) }

          it { is_expected.to permit_action(:show) }

          context "when the participant profile is withdrawn" do
            let(:profile) { create(:participant_profile, profile_type, :withdrawn_record) }

            it { is_expected.to forbid_action(:show) }
          end
        end

        context "when from another school" do
          let(:acting_user) { create(:user, :induction_coordinator) }
          it { is_expected.to forbid_action(:show) }
        end
      end

      context "being another user type" do
        let(:acting_user) { create(:user) }

        it { is_expected.to forbid_new_and_create_actions }
        it { is_expected.to forbid_edit_and_update_actions }
        it { is_expected.to forbid_action(:destroy) }
      end
    end
  end
end

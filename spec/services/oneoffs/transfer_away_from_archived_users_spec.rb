# frozen_string_literal: true

RSpec.describe Oneoffs::TransferAwayFromArchivedUsers do
  before { allow(Rails.logger).to receive(:info) }

  let(:instance) { described_class.new }

  describe "#perform_change" do
    let(:dry_run) { false }

    subject(:perform_change) { instance.perform_change(dry_run:) }

    let(:archived_user_teacher_profile) { participant_profile_on_archived_user.teacher_profile }
    let!(:participant_profile_on_archived_user) { create(:ect_participant_profile, user: create(:user, :archived)) }
    let!(:primary_teacher_profile) { travel_to(1.day.ago) { create(:teacher_profile, trn: archived_user_teacher_profile.trn) } }

    it { is_expected.to eq(instance.recorded_info) }
    it { expect { perform_change }.to change { archived_user_teacher_profile.reload.trn }.to(nil) }
    it { expect { perform_change }.not_to change { primary_teacher_profile.reload.trn } }

    it "transfers away from the archived user" do
      expect(Identity::Transfer).to receive(:call).with(
        from_user: participant_profile_on_archived_user.user,
        to_user: primary_teacher_profile.user,
      )

      perform_change
    end

    it "logs out information" do
      perform_change

      expect(instance).to have_recorded_info([
        "Transferred archived user #{archived_user_teacher_profile.user_id} to #{primary_teacher_profile.user_id}",
      ])
    end

    it "logs out when the teacher profile does not have a trn" do
      archived_user_teacher_profile.update!(trn: nil)
      perform_change
      expect(instance).to have_recorded_info([
        "teacher profile #{archived_user_teacher_profile.id} does not have a trn",
      ])
    end

    it "logs out when the trn cannot be matched to a primary user" do
      primary_teacher_profile.update!(trn: "different-trn")
      perform_change
      expect(instance).to have_recorded_info([
        "primary user not found for trn #{archived_user_teacher_profile.trn}",
      ])
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not make any changes, but records the changes it would make" do
        expect { perform_change }.not_to change { archived_user_teacher_profile.reload.trn }

        expect(instance).to have_recorded_info([
          "~~~ DRY RUN ~~~",
          "Transferred archived user #{archived_user_teacher_profile.user_id} to #{primary_teacher_profile.user_id}",
        ])
      end
    end
  end
end

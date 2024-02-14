# frozen_string_literal: true

describe Oneoffs::PopulateMissingTrns do
  let(:instance) { described_class.new }

  before { allow(Rails.logger).to receive(:info) }

  describe "#perform_change" do
    let(:user) { create(:user) }
    let!(:teacher_profile) { create(:teacher_profile, user:, trn: nil) }
    let(:dry_run) { false }

    subject(:perform_change) { instance.perform_change(dry_run:) }

    it { is_expected.to eq(instance.recorded_info) }

    context "when the teacher profile is associated with an application containing an unverified trn" do
      let!(:npq_application) { create(:npq_application, user:, teacher_reference_number_verified: false) }

      it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }
    end

    context "when the teacher profile is associated with an application containing a verified, invalid trn" do
      let!(:npq_application) { create(:npq_application, user:, teacher_reference_number: "invalid-trn", teacher_reference_number_verified: true) }

      it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }
    end

    context "when the teacher profile is associated with an application containing a verified, valid trn" do
      let!(:npq_application) { create(:npq_application, user:, teacher_reference_number_verified: true) }

      it { expect { perform_change }.to change { teacher_profile.reload.trn }.from(nil).to(npq_application.teacher_reference_number) }

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "teacher profile TRN updated to #{npq_application.teacher_reference_number} for teacher profile #{teacher_profile.id}",
        ])
      end
    end

    context "when the teacher profile is associated with participant validation data containing an invalid trn" do
      let!(:participant_profile) { create(:ect, :eligible_for_funding, teacher_profile:) }

      before do
        participant_profile.ecf_participant_validation_data.update!(trn: "invalid-trn")
        teacher_profile.update!(trn: nil)
      end

      it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }
    end

    context "when the teacher profile is associated with participant validation data containing a valid trn" do
      let!(:participant_profile) { create(:ect, :eligible_for_funding, teacher_profile:) }

      before { teacher_profile.update!(trn: nil) }

      it { expect { perform_change }.to change { teacher_profile.reload.trn }.from(nil).to(participant_profile.ecf_participant_validation_data.trn) }

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "teacher profile TRN updated to #{participant_profile.ecf_participant_validation_data.trn} for teacher profile #{teacher_profile.id}",
        ])
      end
    end

    context "when the teacher profile is associated with another teacher profile with an invalid trn" do
      let(:other_teacher_profile) { create(:teacher_profile, trn: "invalid-trn") }
      let!(:participant_id_change) { create(:participant_id_change, from_participant_id: other_teacher_profile.user_id, to_participant_id: user.id) }

      it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }
    end

    context "when the teacher profile is associated with another teacher profile a valid trn" do
      let(:other_teacher_profile) { create(:teacher_profile) }
      let!(:participant_id_change) { create(:participant_id_change, from_participant_id: other_teacher_profile.user_id, to_participant_id: user.id) }

      it { expect { perform_change }.to change { teacher_profile.reload.trn }.from(nil).to(other_teacher_profile.trn) }

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "teacher profile TRN updated to #{other_teacher_profile.trn} for teacher profile #{teacher_profile.id}",
        ])
      end
    end

    context "when a participant id change exists and the other user has a valid/verified trn" do
      let(:other_user) { create(:user) }
      let!(:other_user_npq_application) { create(:npq_application, user: other_user, teacher_reference_number_verified: true) }
      let!(:participant_id_change) { create(:participant_id_change, from_participant_id: user.id, to_participant_id: other_user.id) }

      it { expect { perform_change }.to change { teacher_profile.reload.trn }.from(nil).to(other_user_npq_application.teacher_reference_number) }

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "teacher profile TRN updated to #{other_user_npq_application.teacher_reference_number} for teacher profile #{teacher_profile.id}",
        ])
      end
    end

    context "when there are multiple, verified trns associated with the teacher profile" do
      let!(:npq_application_1) { create(:npq_application, user:, teacher_reference_number_verified: true) }
      let!(:npq_application_2) { create(:npq_application, user:, teacher_reference_number_verified: true) }
      let(:trns) { [npq_application_1.teacher_reference_number, npq_application_2.teacher_reference_number] }

      it { expect { perform_change }.to change { teacher_profile.reload.trn }.from(nil).to(npq_application_1.teacher_reference_number) }

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "teacher profile TRN updated to #{npq_application_1.teacher_reference_number} for teacher profile #{teacher_profile.id}",
          "multiple TRNs found for teacher profile #{teacher_profile.id}: #{trns.join}",
        ])
      end
    end

    context "when dry_run is true" do
      let(:dry_run) { true }
      let!(:npq_application) { create(:npq_application, user:, teacher_reference_number_verified: true) }

      it "does not make any changes, but records the changes it would make" do
        expect { perform_change }.not_to change { teacher_profile.reload.trn }

        expect(instance).to have_recorded_info([
          "~~~ DRY RUN ~~~",
          "teacher profile TRN updated to #{npq_application.teacher_reference_number} for teacher profile #{teacher_profile.id}",
        ])
      end
    end
  end
end

# frozen_string_literal: true

describe Oneoffs::PopulateMissingTrns do
  let(:instance) { described_class.new }

  before { allow(Rails.logger).to receive(:info) }

  describe "#perform_change" do
    let(:user) { create(:user, :npq) }
    let!(:teacher_profile) { user.teacher_profile.tap { |tp| tp.update(trn: nil) } }
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

      context "when another teacher profile has the same TRN" do
        let!(:other_teacher_profile) { create(:teacher_profile, trn: npq_application.teacher_reference_number) }

        it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }
      end

      context "when the TRN is not formatted correctly" do
        let!(:npq_application) { create(:npq_application, user:, teacher_reference_number_verified: true, teacher_reference_number: "1 2 3 4 5 6 7") }

        it { expect { perform_change }.to change { teacher_profile.reload.trn }.from(nil).to("1234567") }
      end

      context "when it is an ECT teacher profile" do
        let(:user) { create(:user, :early_career_teacher) }

        it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }
      end

      context "when it is a mentor teacher profile" do
        let(:user) { create(:user, :mentor) }

        it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }
      end
    end

    context "when there are multiple, verified trns associated with the teacher profile" do
      let!(:npq_application_1) { create(:npq_application, user:, teacher_reference_number: "1234567", teacher_reference_number_verified: true) }
      let!(:npq_application_2) { travel_to(1.day.from_now) { create(:npq_application, user:, teacher_reference_number: "7654321", teacher_reference_number_verified: true) } }
      let(:trns) { [npq_application_1.teacher_reference_number, npq_application_2.teacher_reference_number] }

      it { expect { perform_change }.not_to change { teacher_profile.reload.trn } }

      it "logs out information" do
        perform_change

        expect(instance).to have_recorded_info([
          "multiple TRNs found for teacher profile #{teacher_profile.id} - ignoring: #{trns.join(', ')}",
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

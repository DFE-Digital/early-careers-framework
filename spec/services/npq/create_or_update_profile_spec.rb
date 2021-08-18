# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::CreateOrUpdateProfile do
  subject do
    described_class.new(npq_validation_data: npq_validation_data)
  end

  describe "#call" do
    let(:trn) { rand(1_000_000..9_999_999).to_s }
    let(:user) { create(:user) }
    let(:npq_course) { create(:npq_course) }
    let(:npq_lead_provider) { create(:npq_lead_provider) }

    let(:npq_validation_data) do
      NPQValidationData.new(
        teacher_reference_number: trn,
        user: user,
        npq_course: npq_course,
        npq_lead_provider: npq_lead_provider,
      )
    end

    context "after creating a NPQValidationData record" do
      before do
        npq_validation_data.save!
      end

      it "creates teacher and participant profile" do
        expect { subject.call }
          .to change(TeacherProfile, :count).by(1)
          .and change(ParticipantProfile::NPQ, :count).by(1)
      end

      it "stores the TRN on teacher profile" do
        subject.call
        npq_validation_data.reload
        expect(npq_validation_data.user.teacher_profile.trn).to eql trn
      end
    end

    context "after updating an existing NPQValidationData record" do
      before do
        npq_validation_data.save!
        subject.call
      end

      let(:new_trn) { (trn.to_i + 1).to_s }

      it "does not create neither teacher nor participant profile" do
        npq_validation_data.update!(teacher_reference_number: new_trn)

        expect { subject.call }
          .to change(TeacherProfile, :count).by(0)
          .and change(ParticipantProfile::NPQ, :count).by(0)
      end

      it "updates the TRN on teacher profile" do
        npq_validation_data.update!(teacher_reference_number: new_trn)

        subject.call

        expect(npq_validation_data.reload.user.teacher_profile.trn).to eql new_trn
      end
    end
  end
end

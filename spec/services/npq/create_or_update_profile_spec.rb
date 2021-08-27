# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::CreateOrUpdateProfile do
  before do
    Finance::Schedule.find_or_create_by(name: "ECF September standard 2021")
  end

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
        school_urn: "123456",
        school_ukprn: "12345678",
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

      it "creates participant profile correctly" do
        subject.call

        profile = user.teacher_profile.npq_profiles.last

        expect(profile.schedule).to eql(Finance::Schedule.default)
        expect(profile.npq_course).to eql(npq_validation_data.npq_course)
        expect(profile.teacher_profile).to eql(user.teacher_profile)
        expect(profile.user).to eql(user)
        expect(profile.school_urn).to eql(npq_validation_data.school_urn)
        expect(profile.school_ukprn).to eql(npq_validation_data.school_ukprn)
      end

      context "when trn is validated" do
        let(:npq_validation_data) do
          NPQValidationData.new(
            teacher_reference_number: trn,
            teacher_reference_number_verified: true,
            user: user,
            npq_course: npq_course,
            npq_lead_provider: npq_lead_provider,
          )
        end

        it "stores the TRN on teacher profile" do
          subject.call
          npq_validation_data.reload
          expect(npq_validation_data.user.teacher_profile.trn).to eql trn
        end
      end

      context "when trn is not validated" do
        it "does not store the TRN on teacher profile" do
          subject.call
          npq_validation_data.reload
          expect(npq_validation_data.user.teacher_profile.trn).to be_blank
        end
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

      context "context trn now validated" do
        it "updates the TRN on teacher profile" do
          npq_validation_data.update!(teacher_reference_number: new_trn, teacher_reference_number_verified: true)

          subject.call

          expect(npq_validation_data.reload.user.teacher_profile.trn).to eql new_trn
        end
      end
    end
  end
end

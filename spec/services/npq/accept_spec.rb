# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Accept do
  before do
    Finance::Schedule.find_or_create_by(name: "ECF September standard 2021")
  end

  subject do
    described_class.new(npq_application: npq_validation_data)
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

    context "when user has applied for the same course with another provider" do
      let(:other_npq_lead_provider) { create(:npq_lead_provider) }

      let(:other_npq_validation_data) do
        NPQValidationData.new(
          teacher_reference_number: trn,
          user: user,
          npq_course: npq_course,
          npq_lead_provider: other_npq_lead_provider,
          school_urn: "123456",
          school_ukprn: "12345678",
        )
      end

      before do
        npq_validation_data.save!
        other_npq_validation_data.save!
      end

      it "rejects other_npq_validation_data" do
        described_class.call(npq_application: npq_validation_data)
        expect(npq_validation_data.reload.lead_provider_approval_status).to eql("accepted")
        expect(other_npq_validation_data.reload.lead_provider_approval_status).to eql("rejected")
      end
    end

    context "when user has applied for different course" do
      let(:other_npq_lead_provider) { create(:npq_lead_provider) }
      let(:other_npq_course) { create(:npq_course) }

      let(:other_npq_validation_data) do
        NPQValidationData.new(
          teacher_reference_number: trn,
          user: user,
          npq_course: other_npq_course,
          npq_lead_provider: other_npq_lead_provider,
          school_urn: "123456",
          school_ukprn: "12345678",
        )
      end

      before do
        npq_validation_data.save!
        other_npq_validation_data.save!
      end

      it "does not reject the other course" do
        described_class.call(npq_application: npq_validation_data)
        expect(npq_validation_data.reload.lead_provider_approval_status).to eql("accepted")
        expect(other_npq_validation_data.reload.lead_provider_approval_status).to eql("pending")
      end
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

        profile = user.teacher_profile.npq_profiles&.first

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

    context "after approving an existing NPQValidationData record" do
      before do
        npq_validation_data.save!
        subject.call
      end

      let(:new_trn) { (trn.to_i + 1).to_s }

      it "does not create neither teacher nor participant profile" do
        npq_validation_data.update!(teacher_reference_number: new_trn)

        expect { subject.call }
          .to raise_error(ActionController::BadRequest, "This NPQ application has alredy been accepted")
          .and change(TeacherProfile, :count).by(0)
          .and change(ParticipantProfile::NPQ, :count).by(0)
      end
    end
  end
end

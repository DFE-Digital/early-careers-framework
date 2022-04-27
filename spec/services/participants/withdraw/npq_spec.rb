# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::Withdraw::NPQ do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_application) { create(:npq_application, npq_lead_provider: npq_lead_provider) }
  let(:profile) { create(:npq_participant_profile, npq_application: npq_application) }
  let(:user) { profile.user }
  let(:npq_course) { profile.npq_course }

  subject do
    described_class.new(
      params: {
        participant_id: user.id,
        course_identifier: npq_course.identifier,
        cpd_lead_provider: cpd_lead_provider,
        reason: "insufficient-capacity-to-undertake-programme",
      },
    )
  end

  describe "#call" do
    it "updates profile training_status to withdrawn" do
      expect { subject.call }.to change { profile.reload.training_status }.from("active").to("withdrawn")
    end

    context "when status is withdrawn" do
      before do
        profile.update!(status: "withdrawn")
      end

      xit "returns an error and does not update training_status" do
        # TODO: there is a gap and bug here
        # it should return a useful error
        # but throws an error as we scope to active profiles only and therefore never find the record
      end
    end

    context "without a reason" do
      subject do
        described_class.new(
          params: {
            participant_id: user.id,
            course_identifier: npq_course.identifier,
            cpd_lead_provider: cpd_lead_provider,
          },
        )
      end

      it "returns an error and does not update training_status" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing).and not_change { profile.reload.training_status }
      end
    end

    context "with a bogus reason" do
      subject do
        described_class.new(
          params: {
            participant_id: user.id,
            course_identifier: npq_course.identifier,
            cpd_lead_provider: cpd_lead_provider,
            reason: "foo",
          },
        )
      end

      it "returns an error and does not update training_status" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing).and not_change { profile.reload.training_status }
      end
    end
  end
end

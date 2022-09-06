# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::Resume::EarlyCareerTeacher, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider)     { cpd_lead_provider.lead_provider }
  let!(:profile)          { create(:ect, :deferred, lead_provider:) }

  subject do
    described_class.new(
      params: {
        participant_id: profile.user_id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
      },
    )
  end

  describe "#call" do
    it "updates profile training_status to active" do
      expect { subject.call }.to change { profile.reload.training_status }.from("deferred").to("active")
    end

    it "updates induction_record training_status to active" do
      expect { subject.call }.to change { profile.current_induction_record.reload.training_status }.from("deferred").to("active")
    end

    it "creates a ParticipantProfileState" do
      expect { subject.call }.to change { profile.participant_profile_states.count }.by(1)
    end

    context "when already active" do
      before do
        described_class.new(
          params: {
            participant_id: profile.user_id,
            course_identifier: "ecf-induction",
            cpd_lead_provider:,
            reason: "bereavement",
          },
        ).call # must be different instance from subject
      end

      it "raises an error and does not create a ParticipantProfileState" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing).and not_change { ParticipantProfileState.count }
      end
    end

    context "when status is withdrawn" do
      before do
        ParticipantProfileState.create!(participant_profile: profile, state: "withdrawn")
        profile.update!(status: "withdrawn")
      end

      xit "returns an error and does not update training_status" do
        # TODO: there is a gap and bug here
        # it should return a useful error
        # but throws an error as we scope to active profiles only and therefore never find the record
      end
    end
  end
end

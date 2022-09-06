# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::Withdraw::EarlyCareerTeacher, :with_default_schedules do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider)     { cpd_lead_provider.lead_provider }
  let(:profile)           { create(:ect, lead_provider:) }

  let!(:induction_coordinator_profile) do
    create(
      :induction_coordinator_profile,
      schools: [profile.school_cohort.school],
    )
  end

  subject do
    described_class.new(
      params: {
        participant_id: profile.user_id,
        course_identifier: "ecf-induction",
        cpd_lead_provider:,
        reason: "left-teaching-profession",
      },
    )
  end

  describe "#call" do
    it "updates profile training_status to withdrawn" do
      expect { subject.call }.to change { profile.reload.training_status }.from("active").to("withdrawn")
    end

    it "updates induction record training_status to withdrawn" do
      expect { subject.call }.to change { profile.current_induction_record.training_status }.from("active").to("withdrawn")
    end

    it "creates a ParticipantProfileState" do
      expect { subject.call }.to change { ParticipantProfileState.count }.by(1)
    end

    it "sends an email to confirm a participant has been withdrawn" do
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(SchoolMailer).to receive(:fip_provider_has_withdrawn_a_participant).and_return(mailer)

      subject.call

      expect(SchoolMailer).to have_received(:fip_provider_has_withdrawn_a_participant).with(
        withdrawn_participant: profile,
        induction_coordinator: induction_coordinator_profile,
      )
    end

    context "when already withdrawn" do
      before do
        described_class.new(
          params: {
            participant_id: profile.user_id,
            course_identifier: "ecf-induction",
            cpd_lead_provider:,
            reason: "left-teaching-profession",
          },
        ).call # must be different instance from subject
      end

      it "raises an error and does not create a ParticipantProfileState" do
        expect { subject.call }.to raise_error(ActionController::ParameterMissing).and not_change { ParticipantProfileState.count }
      end
    end

    context "when status is withdrawn" do
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
            participant_id: profile.user_id,
            course_identifier: "ecf-induction",
            cpd_lead_provider:,
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
            participant_id: profile.user_id,
            course_identifier: "ecf-induction",
            cpd_lead_provider:,
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

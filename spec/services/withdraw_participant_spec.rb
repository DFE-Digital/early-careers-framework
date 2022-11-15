# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validating a participant to be withdrawn" do
  context "when the reason missing" do
    let(:reason) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:reason)).to include("The property '#/reason' must be present")
    end
  end

  context "when the reason is an invalid value" do
    let(:reason) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:reason)).to include("The property '#/reason' must be a valid reason")
    end
  end

  context "when the course identifier is missing" do
    let(:course_identifier) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The property '#/course_identifier' must be an available course to '#/participant_id'")
    end
  end

  context "when the course identifier is an invalid value" do
    let(:course_identifier) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The property '#/course_identifier' must be an available course to '#/participant_id'")
    end
  end

  context "when the participant identifier is missing" do
    let(:participant_id) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end

  context "when the participant identifier is an invalid value" do
    let(:participant_id) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end

  context "when the participant does not belong to the CPD lead provider" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("The property '#/participant_id' must be a valid Participant ID")
    end
  end
end

RSpec.shared_examples "validating a participant is not already withdrawn for a withdraw" do
  it "is invalid and returns an error message" do
    is_expected.to be_invalid

    expect(service.errors.messages_for(:participant_profile)).to include("The participant is already withdrawn")
  end
end

RSpec.shared_examples "withdrawing a participant" do
  it "creates a participant profile state" do
    expect { service.call }.to change { ParticipantProfileState.count }
  end

  it "sets the correct attributes to the new participant profile state" do
    service.call
    latest_participant_profile_state = participant_profile.participant_profile_states.order(created_at: :desc).first

    expect(latest_participant_profile_state).to have_attributes(
      participant_profile_id: participant_profile.id,
      state: "withdrawn",
    )
  end

  it "marks the participant profile as withdrawn" do
    expect { service.call }.to change { participant_profile.reload.training_status }.from("active").to("withdrawn")
  end
end

RSpec.shared_examples "withdrawing an ECF participant" do
  let(:induction_coordinator) { participant_profile.school.induction_coordinator_profiles.first }

  it_behaves_like "withdrawing a participant"

  it "sends an alert email to the provider" do
    expect {
      service.call
    }.to have_enqueued_mail(SchoolMailer, :fip_provider_has_withdrawn_a_participant)
      .with(
        withdrawn_participant: participant_profile,
        induction_coordinator:,
      ).once
  end

  it "creates a new withdrawn induction record" do
    expect { service.call }.to change { InductionRecord.count }
  end

  it "adds the correct attributes to the new induction_record" do
    service.call

    expect(participant_profile.induction_records.latest.training_status).to eq("withdrawn")
  end
end

RSpec.shared_examples "withdrawing a NPQ participant" do
  it_behaves_like "withdrawing a participant"

  it "does not send an alert email to the provider" do
    expect {
      service.call
    }.not_to have_enqueued_mail(SchoolMailer, :fip_provider_has_withdrawn_a_participant)
  end
end

RSpec.describe WithdrawParticipant, :with_default_schedules do
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:induction_record) { participant_profile.induction_records.first }
  let(:reason) { "other" }
  let(:params) do
    {
      cpd_lead_provider:,
      participant_id:,
      course_identifier:,
      reason:,
    }
  end

  subject(:service) do
    described_class.new(params)
  end

  context "ECT participant profile" do
    let(:cpd_lead_provider) { induction_record.cpd_lead_provider }
    let(:participant_profile) { create(:ect) }
    let(:course_identifier) { "ecf-induction" }

    describe "validations" do
      it_behaves_like "validating a participant to be withdrawn"

      it_behaves_like "validating a participant is not already withdrawn for a withdraw" do
        let(:participant_profile) { create(:ect, :withdrawn) }
      end
    end

    describe ".call" do
      it_behaves_like "withdrawing an ECF participant"
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { induction_record.cpd_lead_provider }
    let(:participant_profile) { create(:mentor) }
    let(:course_identifier) { "ecf-mentor" }

    describe "validations" do
      it_behaves_like "validating a participant to be withdrawn"

      it_behaves_like "validating a participant is not already withdrawn for a withdraw" do
        let(:participant_profile) { create(:mentor, :withdrawn) }
      end
    end

    describe ".call" do
      it_behaves_like "withdrawing an ECF participant"
    end
  end

  context "NPQ participant profile" do
    let(:cpd_lead_provider) { npq_application.npq_lead_provider.cpd_lead_provider }
    let(:school) { create(:school) }
    let(:npq_application) { create(:npq_application, :accepted, :with_started_declaration, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }
    let(:participant_profile) { create(:npq_participant_profile, npq_application:, school:) }
    let(:course_identifier) { npq_application.npq_course.identifier }
    let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school]) }

    describe "validations" do
      it_behaves_like "validating a participant to be withdrawn"

      it_behaves_like "validating a participant is not already withdrawn for a withdraw" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn, npq_application:) }
      end

      context "when a participant has no started declarations" do
        let(:npq_application) { create(:npq_application, :accepted, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_profile)).to include("An NPQ participant who has not got a started declaration cannot be withdrawn. Please contact support for assistance")
        end
      end
    end

    describe ".call" do
      it_behaves_like "withdrawing a NPQ participant"
    end
  end
end

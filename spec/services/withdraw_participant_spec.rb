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

      expect(service.errors.messages_for(:course_identifier)).to include("The entered '#/course_identifier' is not recognised for the given participant. Check details and try again.")
    end
  end

  context "when the course identifier is an invalid value" do
    let(:course_identifier) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The entered '#/course_identifier' is not recognised for the given participant. Check details and try again.")
    end
  end

  context "when the participant identifier is missing" do
    let(:participant_id) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
    end
  end

  context "when the participant identifier is an invalid value" do
    let(:participant_id) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
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

  context "when the participant has a different user ID to external ID" do
    let(:participant_identity) { create(:participant_identity, :secondary) }

    before { participant_profile.update!(participant_identity:) }

    it "marks the participant profile as withdrawn" do
      expect { service.call }.to change { participant_profile.reload.training_status }.from("active").to("withdrawn")
    end
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
        params: {
          withdrawn_participant: participant_profile,
          induction_coordinator:,
        },
        args: [],
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

RSpec.describe WithdrawParticipant do
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
  let(:participant_identity) { create(:participant_identity) }
  let(:user) { participant_identity.user }

  subject(:service) do
    described_class.new(params)
  end

  context "ECT participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-induction" }

    describe "validations" do
      it_behaves_like "validating a participant to be withdrawn"

      it_behaves_like "validating a participant is not already withdrawn for a withdraw" do
        let(:participant_profile) { create(:ect, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end

      context "when the participant does not belong to the CPD lead provider" do
        let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:participant_profile) { create(:ect, lead_provider: another_cpd_lead_provider.lead_provider, user:) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
        end
      end
    end

    describe ".call" do
      it_behaves_like "withdrawing an ECF participant"
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-mentor" }
    let!(:schedule) { create(:ecf_mentor_schedule, schedule_identifier: "ecf-extended-april", name: "Mentor Standard") }

    describe "validations" do
      it_behaves_like "validating a participant to be withdrawn"

      it_behaves_like "validating a participant is not already withdrawn for a withdraw" do
        let(:participant_profile) { create(:mentor, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end

      context "when the participant does not belong to the CPD lead provider" do
        let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:participant_profile) { create(:mentor, lead_provider: another_cpd_lead_provider.lead_provider, user:) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
        end
      end
    end

    describe ".call" do
      it_behaves_like "withdrawing an ECF participant"
    end
  end

  context "NPQ participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let(:schedule) { create(:npq_specialist_schedule) }
    let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, schedule:, user:) }
    let(:course_identifier) { npq_course.identifier }
    let(:school) { create(:school) }
    let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school]) }

    describe "validations" do
      it_behaves_like "validating a participant to be withdrawn"

      it_behaves_like "validating a participant is not already withdrawn for a withdraw" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn, npq_lead_provider:, npq_course:) }
      end

      context "when a participant has no started declarations" do
        let(:npq_application) { create(:npq_application, :accepted, npq_course: create(:npq_course, identifier: "npq-senior-leadership")) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_profile)).to include("An NPQ participant who has not got a started declaration cannot be withdrawn. Please contact support for assistance")
        end
      end

      context "when the participant does not belong to the CPD lead provider" do
        let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
        let(:another_npq_lead_provider) { another_cpd_lead_provider.npq_lead_provider }
        let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider: another_npq_lead_provider) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
        end
      end
    end

    describe ".call" do
      it_behaves_like "withdrawing a NPQ participant"
    end
  end
end

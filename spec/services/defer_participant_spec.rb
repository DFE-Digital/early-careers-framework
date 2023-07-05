# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validating deferring a participant attributes" do
  context "when the reason missing" do
    let(:reason) {}

    it "is invalid returning a meaningful error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:reason)).to include("The property '#/reason' must be present")
    end
  end

  context "when the reason is an invalid value" do
    let(:reason) { "invalid-value" }

    it "is invalid returning a meaningful error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:reason)).to include("The property '#/reason' must be a valid reason")
    end
  end

  context "when the course identifier missing" do
    let(:course_identifier) {}

    it "is invalid returning a meaningful error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The entered '#/course_identifier' is not recognised for the given participant. Check details and try again.")
    end
  end

  context "when the course identifier is an invalid value" do
    let(:course_identifier) { "invalid-value" }

    it "is invalid returning a meaningful error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The entered '#/course_identifier' is not recognised for the given participant. Check details and try again.")
    end
  end

  context "when the participant identifier is missing" do
    let(:participant_id) {}

    it "is invalid returning a meaningful error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
    end
  end

  context "when the participant identifier is an invalid value" do
    let(:participant_id) { "invalid-value" }

    it "is invalid returning a meaningful error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
    end
  end
end

RSpec.shared_examples "validating a participant is not already deferred" do
  it "is invalid returning a meaningful error message" do
    is_expected.to be_invalid

    expect(service.errors.messages_for(:participant_profile)).to include("The participant is already deferred")
  end
end

RSpec.shared_examples "validating a participant is not withdrawn for a defer" do
  it "is invalid returning a meaningful error message" do
    is_expected.to be_invalid

    expect(service.errors.messages_for(:participant_profile)).to include("The participant is already withdrawn")
  end
end

RSpec.shared_examples "deferring a participant" do
  it "creates a deferred participant profile state" do
    expect { service.call }.to change { ParticipantProfileState.count }
  end

  it "adds the correct attributes to the new participant profile state" do
    service.call
    latest_participant_profile = participant_profile.participant_profile_states.order(created_at: :desc).first
    expect(latest_participant_profile).to have_attributes(
      state: "deferred",
      cpd_lead_provider:,
      reason: "other",
    )
  end

  it "marks the participant profiles as deferred" do
    expect { service.call }.to change { participant_profile.reload.training_status }.from("active").to("deferred")
  end

  context "when the participant has a different user ID to external ID" do
    let(:participant_identity) { create(:participant_identity, :secondary) }

    before { participant_profile.update!(participant_identity:) }

    it "marks the participant profiles as deferred" do
      expect { service.call }.to change { participant_profile.reload.training_status }.from("active").to("deferred")
    end
  end
end

RSpec.shared_examples "deferring an ECF participant" do
  it_behaves_like "deferring a participant"

  it "creates a new deferred induction record" do
    expect { service.call }.to change { InductionRecord.count }
  end

  it "adds the correct attributes to the new induction_record" do
    service.call

    expect(participant_profile.induction_records.latest.training_status).to eq("deferred")
  end
end

RSpec.describe DeferParticipant do
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:reason) { "other" }
  let(:params) do
    {
      cpd_lead_provider:,
      participant_id:,
      reason:,
      course_identifier:,
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
      it_behaves_like "validating deferring a participant attributes"

      it_behaves_like "validating a participant is not already deferred" do
        let(:participant_profile) { create(:ect, :deferred, lead_provider: cpd_lead_provider.lead_provider) }
      end

      it_behaves_like "validating a participant is not withdrawn for a defer" do
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
      it_behaves_like "deferring an ECF participant"
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-mentor" }

    describe "validations" do
      it_behaves_like "validating deferring a participant attributes"

      it_behaves_like "validating a participant is not already deferred" do
        let(:participant_profile) { create(:mentor, :deferred, lead_provider: cpd_lead_provider.lead_provider) }
      end

      it_behaves_like "validating a participant is not withdrawn for a defer" do
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
      it_behaves_like "deferring an ECF participant"
    end
  end

  context "NPQ participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let(:schedule) { create(:npq_specialist_schedule) }
    let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, schedule:, user:) }
    let(:course_identifier) { npq_course.identifier }

    describe "validations" do
      it_behaves_like "validating deferring a participant attributes"

      it_behaves_like "validating a participant is not already deferred" do
        let(:participant_profile) { create(:npq_participant_profile, :deferred, npq_lead_provider:, npq_course:) }
      end

      it_behaves_like "validating a participant is not withdrawn for a defer" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn, npq_lead_provider:, npq_course:) }
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
      it_behaves_like "deferring a participant"
    end
  end
end

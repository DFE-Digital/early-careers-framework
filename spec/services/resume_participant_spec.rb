# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validating resuming a participant attributes" do
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

RSpec.shared_examples "validating a participant is not already active" do
  it "is invalid returning a meaningful error message" do
    is_expected.to be_invalid

    expect(service.errors.messages_for(:participant_profile)).to include("The participant is already active")
  end
end

RSpec.shared_examples "resuming a participant" do
  it "creates an active participant profile state" do
    expect { service.call }.to change { ParticipantProfileState.count }
  end

  it "adds the correct attributes to the new participant profile state" do
    service.call
    latest_participant_profile = participant_profile.participant_profile_states.order(created_at: :desc).first
    expect(latest_participant_profile).to have_attributes(
      state: "active",
      cpd_lead_provider:,
    )
  end

  it "marks the participant profiles as active" do
    expect { service.call }.to change { participant_profile.reload.training_status }.from("deferred").to("active")
  end

  context "when the participant has a different user ID to external ID" do
    let(:participant_identity) { create(:participant_identity, :secondary) }

    before { participant_profile.update!(participant_identity:) }

    it "marks the participant profiles as active" do
      expect { service.call }.to change { participant_profile.reload.training_status }.from("deferred").to("active")
    end
  end
end

RSpec.shared_examples "resuming an ECF participant" do
  it_behaves_like "resuming a participant"

  it "creates a new active induction record" do
    expect { service.call }.to change { InductionRecord.count }
  end

  it "adds the correct attributes to the new induction_record" do
    service.call

    expect(participant_profile.induction_records.latest).to be_training_status_active
  end
end

RSpec.shared_examples "resuming a withdrawn participant" do
  it "creates an active participant profile state" do
    expect { service.call }.to change { ParticipantProfileState.count }
  end

  it "adds the correct attributes to the new participant profile state" do
    service.call
    latest_participant_profile = participant_profile.participant_profile_states.order(created_at: :desc).first
    expect(latest_participant_profile).to have_attributes(
      state: "active",
      cpd_lead_provider:,
    )
  end

  it "marks the participant profiles as active" do
    expect { service.call }.to change { participant_profile.reload.training_status }.from("withdrawn").to("active")
  end
end

RSpec.describe ResumeParticipant do
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:params) do
    {
      cpd_lead_provider:,
      participant_id:,
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
    let(:participant_profile) { create(:ect, :deferred, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-induction" }

    describe "validations" do
      it_behaves_like "validating resuming a participant attributes"

      it_behaves_like "validating a participant is not already active" do
        let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
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
      it_behaves_like "resuming an ECF participant"

      it_behaves_like "resuming a withdrawn participant" do
        let(:participant_profile) { create(:ect, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:mentor, :deferred, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-mentor" }

    describe "validations" do
      it_behaves_like "validating resuming a participant attributes"

      it_behaves_like "validating a participant is not already active" do
        let(:participant_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider) }
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
      it_behaves_like "resuming an ECF participant"

      it_behaves_like "resuming a withdrawn participant" do
        let(:participant_profile) { create(:mentor, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end
    end
  end
end

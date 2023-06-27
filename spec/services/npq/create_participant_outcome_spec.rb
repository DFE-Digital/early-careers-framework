# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::CreateParticipantOutcome do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_application) { create(:npq_application, :eligible_for_funding, :accepted, npq_lead_provider:) }
  let(:participant_profile) { npq_application.profile }
  let(:participant_declaration) { create(:npq_participant_declaration, participant_profile:, cpd_lead_provider:) }
  let(:participant_external_id) { participant_profile.participant_identity.external_identifier }
  let(:course_identifier) { npq_application.npq_course.identifier }
  let(:state) { "passed" }
  let(:completion_date) { "2022-11-30" }

  let(:params) do
    {
      cpd_lead_provider:,
      participant_external_id:,
      course_identifier:,
      state:,
      completion_date:,
    }
  end

  subject(:service) { described_class.new(params) }

  describe "#call" do
    context "when the completion date is missing" do
      let(:completion_date) {}

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:completion_date)).to include("The property '#/completion_date' must be present")
      end
    end

    context "when the completion date is an invalid value" do
      let(:completion_date) { "invalid-value" }

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:completion_date)).to include("The property '#/completion_date' must be in the following format: '2021-05-31'")
      end
    end

    context "when the course_identifier is missing" do
      let(:course_identifier) {}

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:course_identifier)).to include("The property '#/course_identifier' must be present")
      end
    end

    context "when the course_identifier is an invalid value" do
      let(:course_identifier) { "invalid-value" }

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:course_identifier)).to include("The property '#/course_identifier' must be an available course to '#/participant_id'")
      end
    end

    context "when the state is missing" do
      let(:state) {}

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:state)).to include("The property '#/state' must be present")
      end
    end

    context "when the state is an invalid value" do
      let(:state) { "invalid-value" }

      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:state)).to include("The attribute '#/state' can only include 'passed' or 'failed' values. If you need to void an outcome, you will need to void the associated 'completed' declaration")
      end
    end

    context "when the participant profile has not a completed declaration" do
      it "is invalid returning a meaningful error message" do
        is_expected.to be_invalid

        expect(service.errors.full_messages).to include("The participant has not not had a 'completed' declaration submitted against them. Therefore you cannot update their outcome")
      end
    end

    context "when the participant profile has a completed declaration" do
      let!(:npq_participant_declaration) { create(:npq_participant_declaration, :eligible, participant_profile:, cpd_lead_provider:) }

      before do
        npq_participant_declaration.update!(declaration_type: "completed")
      end

      it "is valid" do
        is_expected.to be_valid
      end

      it "creates a new participant outcome record" do
        expect { service.call }.to change { ParticipantOutcome::NPQ.count }
      end

      it "adds the correct attributes to the new participant_outcome record" do
        service.call

        expect(npq_participant_declaration.outcomes.latest).to have_attributes(
          state:,
          completion_date: Date.parse(completion_date),
        )
      end

      context "when an outcome with same details already exists" do
        let!(:outcome) { create(:participant_outcome, participant_declaration: npq_participant_declaration, state:, completion_date:) }

        it "does not create a new participant outcome record" do
          expect { service.call }.not_to change { ParticipantOutcome::NPQ.count }
        end

        it "returns the same outcome record" do
          expect(service.call).to eql(outcome)
        end
      end

      context "when an outcome with different details already exists" do
        let!(:outcome) { create(:participant_outcome, participant_declaration: npq_participant_declaration, state: "voided") }

        it "is valid" do
          is_expected.to be_valid
        end

        it "creates a new participant outcome record" do
          expect { service.call }.to change { ParticipantOutcome::NPQ.count }
        end

        it "adds the correct attributes to the new participant_outcome record" do
          service.call

          expect(npq_participant_declaration.outcomes.latest).to have_attributes(
            state:,
            completion_date: Date.parse(completion_date),
          )
        end
      end
    end
  end
end

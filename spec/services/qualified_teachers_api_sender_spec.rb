# frozen_string_literal: true

require "rails_helper"

RSpec.describe QualifiedTeachersApiSender do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:user) { create(:user, full_name: "John Doe") }
  let(:teacher_profile) { create(:teacher_profile, user:, trn: "1234567") }
  let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, teacher_profile:, user:) }
  let(:participant_declaration) { create(:npq_participant_declaration, npq_course:, cpd_lead_provider:, participant_profile:) }
  let(:participant_outcome) { create(:participant_outcome, :passed, participant_declaration:) }
  let!(:participant_outcome_id) { participant_outcome.id }

  let(:params) do
    {
      participant_outcome_id:,
    }
  end

  subject(:service) do
    described_class.new(params)
  end

  describe "validations" do
    context "when the participant outcome id is missing" do
      let(:participant_outcome_id) {}

      it "is invalid and returns an error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:participant_outcome_id)).to include("The property '#/missing_participant_outcome_id' must be present")
      end
    end

    context "when the participant outcome id is an invalid value" do
      let(:participant_outcome_id) { SecureRandom.uuid }

      it "is invalid and returns an error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:participant_outcome)).to include("There's no participant outcome for the given ID")
      end
    end

    context "when the participant outcome has already been successfully sent to the API" do
      let!(:participant_outcome) { create(:participant_outcome, participant_declaration:, qualified_teachers_api_request_successful: true) }

      it "is invalid and returns an error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:participant_outcome)).to include("This participant outcome has already been successfully submitted to Qualified Teachers API (TRA)")
      end
    end

    context "when the participant outcome has already been unsuccessfully sent to the API" do
      let!(:participant_outcome) { create(:participant_outcome, participant_declaration:, qualified_teachers_api_request_successful: false) }

      it "is invalid and returns an error message" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:participant_outcome)).to include("This participant outcome has already been unsuccessfully submitted to Qualified Teachers API (TRA)")
      end
    end
  end

  describe "#call" do
    let(:trn) { participant_outcome.participant_declaration&.participant_profile&.teacher_profile&.trn }
    let(:request_body) do
      {
        completionDate: participant_outcome.completion_date.to_s,
        qualificationType: participant_outcome.participant_declaration.qualification_type,
      }
    end

    before do
      stub_request(:put, "https://qualified-teachers-api.example.com/v2/npq-qualifications?trn=1234567")
        .with(
          body: request_body,
        )
        .to_return(status: 204, body: "", headers: {})
    end

    describe "when no exception is raised" do
      before { allow_any_instance_of(QualifiedTeachers::Client).to receive(:send_record).with({ trn:, request_body: }).and_call_original }

      it "updates sent to qualified teachers api at" do
        expect { service.call }.to change { participant_outcome.reload.sent_to_qualified_teachers_api_at }
      end

      it "creates a new participant outcome api request" do
        expect { service.call }.to change { participant_outcome.reload.participant_outcome_api_requests.size }.from(0).to(1)
      end

      it "updates qualified teachers api request successful" do
        expect { service.call }.to change { participant_outcome.reload.qualified_teachers_api_request_successful? }.from(false).to(true)
      end

      it "returns the participant outcome" do
        expect(service.call).to eq(participant_outcome)
      end

      context "with failed outcome" do
        let(:participant_outcome) { create(:participant_outcome, :failed, participant_declaration:) }
        let(:request_body) do
          {
            completionDate: nil,
            qualificationType: participant_outcome.participant_declaration.qualification_type,
          }
        end

        it "sends a request without a completion date" do
          expect { service.call }.to change { participant_outcome.reload.qualified_teachers_api_request_successful? }.from(false).to(true)
        end
      end

      context "with voided outcome" do
        let(:participant_outcome) { create(:participant_outcome, :voided, participant_declaration:) }
        let(:request_body) do
          {
            completionDate: nil,
            qualificationType: participant_outcome.participant_declaration.qualification_type,
          }
        end

        it "sends a request without a completion date" do
          expect { service.call }.to change { participant_outcome.reload.qualified_teachers_api_request_successful? }.from(false).to(true)
        end
      end
    end

    describe "when an exception is raised" do
      before { allow_any_instance_of(QualifiedTeachers::Client).to receive(:send_record).with({ trn:, request_body: }).and_raise(StandardError) }

      it "does nothing" do
        expect(Sentry).to receive(:capture_exception)

        expect { service.call }.to raise_error(StandardError)
      end
    end
  end
end

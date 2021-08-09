# frozen_string_literal: true

describe "Record Declaration Validation" do
  context "when validating declaration date" do
    let(:participant_profile) { create(:participant_profile, :ect) }
    let(:lead_provider) { create(:lead_provider) }
    let(:lead_provider_profile) { create(:lead_provider_profile, user: user, lead_provider: lead_provider) }

    let(:params) do
      {
        "data": {
          "type": "participant-declaration",
          "attributes": {
            "user_id": participant_profile.user.id.to_s,
            "declaration_type": "started",
            "declaration_date": "2021-05-31 02:21:32",
            "course_identifier": "ecf-induction",
          },
        },
      }
    end

    let(:additional_params) do
      {
        "lead_provider_from_token" => lead_provider.cpd_lead_provider,
      }
    end

    context "when started event" do
      let(:record) { RecordDeclarations::Started::EarlyCareerTeacher.call(params[:data][:attributes].merge(additional_params)) }

      it "should raise a validation error" do
        expected_msg = "param is missing or the value is empty: [\"The property '#/declaration_date' must be a valid RCF3339 date\"]"
        expect { record.valid }.to raise_error(ActionController::ParameterMissing, expected_msg)
      end
    end

    context "when retained event" do
      let(:params) do
        {
          "data": {
            "type": "participant-declaration",
            "attributes": {
              "user_id": participant_profile.user.id.to_s,
              "declaration_type": "retained-1",
              "declaration_date": "2021-05-31 02:21:32",
              "course_identifier": "ecf-induction",
              "evidence_held": "training-event-attended",
            },
          },
        }
      end

      let(:record) { RecordDeclarations::Retained::EarlyCareerTeacher.call(params[:data][:attributes].merge(additional_params)) }

      it "should raise a validation error" do
        expected_msg = "param is missing or the value is empty: [\"The property '#/declaration_date' must be a valid RCF3339 date\"]"
        expect { record.valid }.to raise_error(ActionController::ParameterMissing, expected_msg)
      end
    end

    context "when date is in future" do
      let(:params) do
        {
          "data": {
            "type": "participant-declaration",
            "attributes": {
              "user_id": participant_profile.user.id.to_s,
              "declaration_type": "started",
              "declaration_date": "2121-05-31T02:21:32",
              "course_identifier": "ecf-induction",
              "evidence_held": "training-event-attended",
            },
          },
        }
      end

      let(:record) { RecordDeclarations::Started::EarlyCareerTeacher.call(params[:data][:attributes].merge(additional_params)) }

      it "should raise a validation error" do
        expected_msg = "param is missing or the value is empty: [\"The property '#/declaration_date' can not declare a future date\"]"
        expect { record.valid }.to raise_error(ActionController::ParameterMissing, expected_msg)
      end
    end
  end
end

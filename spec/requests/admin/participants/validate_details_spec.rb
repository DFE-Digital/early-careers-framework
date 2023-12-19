# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants::ValidateDetailsController", type: :request do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create(:user, full_name:) }
  let(:ect_profile) { create(:ect, user:) }
  let!(:validation_data) do
    create(:ecf_participant_validation_data,
           participant_profile: ect_profile,
           full_name:,
           trn:,
           date_of_birth:)
  end
  let(:validation_result) { { a: "value" } }

  let(:full_name) { "John Doe" }
  let(:trn) { "1234567" }
  let(:date_of_birth) { Date.new(1987, 12, 13) }

  before do
    sign_in(admin_user)
    ect_profile.teacher_profile.update!(trn:)
    allow(validation_data).to receive(:can_validate_participant?).and_return(true)
  end

  # This is more indepth than the POST with actual data stubbing because I want to make sure that
  # despite all that, nothing gets persisted to the database.
  describe "GET /admin/participants/:participant_id/validation-data" do
    before do
      stub_request(:get, "https://dtqapi.example.com/dqt-crm/v3/teachers/#{trn}")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "Bearer some-apikey-guid",
            "Host" => "dtqapi.example.com",
            "User-Agent" => "Ruby",
          },
        )
        .to_return(status: 200, body: dqt_response, headers: {})
    end

    context "when the participant has a DQT match" do
      let(:dqt_response) do
        JSON.generate({
          "name": full_name,
          "dob": "#{date_of_birth}T00:00:00",
          "trn": trn,
          "ni_number": "AB123456D",
          "active_alert": false,
          "state_name": "Active",
          "qualified_teacher_status": {
            "qts_date": "2021-07-05T00:00:00Z",
          },
          "induction": {
            "start_date": "2021-09-02T00:00:00Z",
          },
        })
      end

      it "renders successfully" do
        expect {
          get("/admin/participants/#{ect_profile.id}/validate-details/new")
        }.to_not raise_error
      end

      it "does not make any persistant changes to the database" do
        expect {
          get("/admin/participants/#{ect_profile.id}/validate-details/new")
        }.to_not change {
          [
            ect_profile.reload.as_json,
            user.reload.as_json,
            ect_profile.teacher_profile.reload.as_json,
            ect_profile.ecf_participant_validation_data.reload.as_json,
            ect_profile.ecf_participant_eligibility&.reload&.as_json,
          ]
        }
      end
    end

    context "when the participant does not have a DQT match" do
      let(:dqt_response) do
        JSON.generate({
          "name": "#{full_name}-mismatch",
          "dob": "#{date_of_birth}T00:00:00",
          "trn": trn.reverse,
          "ni_number": SecureRandom.uuid,
          "active_alert": false,
          "state_name": "Active",
          "qualified_teacher_status": {
            "qts_date": "2021-07-05T00:00:00Z",
          },
          "induction": {
            "start_date": "2021-09-02T00:00:00Z",
          },
        })
      end

      it "renders successfully" do
        expect {
          get("/admin/participants/#{ect_profile.id}/validate-details/new")
        }.to_not raise_error
      end
    end
  end

  describe "POST /admin/participants/:participant_id/validate-details" do
    before do
      allow(Participants::ParticipantValidationForm).to receive_message_chain(:build, call: validation_result)
      post("/admin/participants/#{ect_profile.id}/validate-details")
    end

    it "validates the validation data" do
      expect(response).to redirect_to("/admin/participants/#{ect_profile.id}/validation-data")
    end

    it "clears the TRN prior to validation" do
      expect(ect_profile.reload.teacher_profile.reload.trn).to be_nil
    end

    context "when an NPQ profile is present" do
      before do
        create(:npq_participant_profile, trn: "1234567", user:)
      end

      it "does not remove the TRN prior to validation" do
        expect(ect_profile.teacher_profile.trn).to eq "1234567"
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants::ValidationDataController", :with_default_schedules, type: :request do
  let(:admin_user) { create(:user, :admin) }

  let(:user) { create(:user, full_name: "John Doe") }
  let(:ect_profile) { create(:ect, user:) }
  let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: ect_profile) }
  let(:validation_result) { { a: "value" } }

  before { sign_in(admin_user) }

  describe "POST /admin/participants/:participant_id/validation-data/validate-details" do
    before do
      ect_profile.teacher_profile.update!(trn: "1234567")
      allow(validation_data).to receive(:can_validate_participant?).and_return(true)
      allow(Participants::ParticipantValidationForm).to receive(:call).and_return(validation_result).once
      post("/admin/participants/#{ect_profile.id}/validation-data/validate-details")
    end

    it "validates the validation data" do
      expect(response).to redirect_to("/admin/participants/#{ect_profile.id}#validation-data")
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

# frozen_string_literal: true

RSpec.shared_examples "a participant action service" do
  context "when lead providers don’t match" do
    it "raises a ParameterMissing error" do
      expect { described_class.call(params: given_params.merge({ cpd_lead_provider: another_lead_provider })) }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when user is not a participant" do
    it "raises ParameterMissing for an invalid user_id and not change participant profile state" do
      expect { described_class.call(params: given_params.except(:participant_id)) }.to raise_error(ActionController::ParameterMissing).and(not_change { ParticipantProfileState.count })
    end
  end
end

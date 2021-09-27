# frozen_string_literal: true

RSpec.shared_examples "a participant defer action service" do
  it_behaves_like "a participant action service"

  it "fails when the reason is invalid" do
    params = given_params.merge({ reason: "wibble" })
    expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
  end

  it "creates a deferred state and makes the profile deferred" do
    expect { described_class.call(params: participant_params) }.to change { ParticipantProfileState.count }.by(1)
    expect(user_profile.participant_profile_state.deferred?)
  end

  it "fails when the participant is already deferred" do
    described_class.call(params: participant_params)
    expect { described_class.call(params: participant_params) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "fails when the participant is already withdrawn" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn")
    expect { described_class.call(params: participant_params) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

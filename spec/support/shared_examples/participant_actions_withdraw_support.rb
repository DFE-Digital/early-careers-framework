# frozen_string_literal: true

RSpec.shared_examples "a participant withdraw action service" do
  it_behaves_like "a participant action service"

  it "fails when the reason is invalid" do
    params = given_params.merge({ reason: "wibble" })
    expect { described_class.call(params: params) }.to raise_error(ActionController::ParameterMissing)
  end

  it "creates a withdrawn state and makes the profile withdrawn" do
    expect { described_class.call(params: given_params) }.to change { ParticipantProfileState.count }.by(1)
    expect(user_profile.participant_profile_state.withdrawn?)
    expect(user_profile.training_status_withdrawn?)
  end

  it "creates a withdrawn state when that user is deferred" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "deferred")
    expect(user_profile.participant_profile_state.deferred?)
    expect { described_class.call(params: given_params) }.to change { ParticipantProfileState.count }.by(1)
    expect(user_profile.participant_profile_state.withdrawn?)
  end

  it "fails when the participant is already withdrawn" do
    described_class.call(params: given_params)
    expect(user_profile.participant_profile_state.withdrawn?)
    expect { described_class.call(params: given_params) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "fails when participant profile is a withdrawn record" do
    user_profile.withdrawn_record!
    expect { described_class.call(params: given_params) }.to raise_error(ActionController::ParameterMissing)
  end
end

# frozen_string_literal: true

RSpec.shared_examples "a participant resume action service" do
  it_behaves_like "a participant action service"

  it "creates an active state and makes the profile active" do
    expect { described_class.call(params: given_params) }.to change { ParticipantProfileState.count }.by(1)
    expect(user_profile.participant_profile_state.active?)
  end

  it "fails when the participant is already active" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "active")
    expect { described_class.call(params: given_params) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "fails when the participant is already withdrawn" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn")
    expect { described_class.call(params: given_params) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

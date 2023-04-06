# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_ect_participant_profile_state, seed_npq_participant_profile_state") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_ect_participant_profile_state }
    let(:factory_class) { ParticipantProfileState }
  end

  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_npq_participant_profile_state }
    let(:factory_class) { ParticipantProfileState }
  end
end

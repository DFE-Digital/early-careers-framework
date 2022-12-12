# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_participant_profile") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_participant_identity }
    let(:factory_class) { ParticipantIdentity }
  end
end

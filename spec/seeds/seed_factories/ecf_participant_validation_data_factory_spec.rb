# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_ecf_participant_validation_data") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_ecf_participant_validation_data }
    let(:factory_class) { ECFParticipantValidationData }
  end
end

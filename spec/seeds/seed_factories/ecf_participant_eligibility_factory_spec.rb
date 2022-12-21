# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_ecf_participant_eligibilty") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_ecf_participant_eligibilty }
    let(:factory_class) { ECFParticipantEligibility }
  end
end

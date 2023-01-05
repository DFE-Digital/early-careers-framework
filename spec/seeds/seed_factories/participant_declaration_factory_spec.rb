# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_ecf_participant_declaration, seed_npq_participant_declaration") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_ecf_participant_declaration }
    let(:factory_class) { ParticipantDeclaration::ECF }
  end

  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_npq_participant_declaration }
    let(:factory_class) { ParticipantDeclaration::NPQ }
  end
end

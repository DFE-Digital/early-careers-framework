# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_ect_participant_declaration, seed_npq_participant_declaration") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_ect_participant_declaration }
    let(:factory_class) { ParticipantDeclaration::ECT }
  end

  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_mentor_participant_declaration }
    let(:factory_class) { ParticipantDeclaration::Mentor }
  end

  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_npq_participant_declaration }
    let(:factory_class) { ParticipantDeclaration::NPQ }
  end
end

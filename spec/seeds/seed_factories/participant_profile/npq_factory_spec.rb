# frozen_string_literal: true

require_relative "../shared_factory_examples"

RSpec.describe("seed_npq_participant_profile") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_npq_participant_profile }
    let(:factory_class) { ParticipantProfile::NPQ }
  end
end

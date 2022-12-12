# frozen_string_literal: true

require_relative "../shared_factory_examples"

RSpec.describe("seed_mentor_participant_profile") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_mentor_participant_profile }
    let(:factory_class) { ParticipantProfile::Mentor }
  end
end

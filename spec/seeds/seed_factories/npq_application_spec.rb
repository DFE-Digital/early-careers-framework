# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_npq_application") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_npq_application }
    let(:factory_class) { NPQApplication }
  end
end

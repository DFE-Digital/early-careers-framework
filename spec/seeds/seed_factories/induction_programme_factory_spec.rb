# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_induction_programme") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_induction_programme }
    let(:factory_class) { InductionProgramme }
  end
end

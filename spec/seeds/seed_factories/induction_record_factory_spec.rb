# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_induction_record") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_induction_record }
    let(:factory_class) { InductionRecord }
  end
end

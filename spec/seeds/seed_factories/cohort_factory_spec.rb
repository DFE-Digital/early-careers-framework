# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_cohort") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_cohort }
    let(:factory_class) { Cohort }
  end
end

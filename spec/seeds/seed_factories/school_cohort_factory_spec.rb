# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_school_cohort_factory") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_school_cohort }
    let(:factory_class) { SchoolCohort }
  end
end

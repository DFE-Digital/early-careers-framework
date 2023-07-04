# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_academic_year") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_academic_year }
    let(:factory_class) { AcademicYear }
  end
end

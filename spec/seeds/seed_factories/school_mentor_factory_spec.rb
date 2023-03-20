# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_school_mentor") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_school_mentor }
    let(:factory_class) { SchoolMentor }
  end
end

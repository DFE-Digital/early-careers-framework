# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_partnership") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_partnership }
    let(:factory_class) { Partnership }
  end
end

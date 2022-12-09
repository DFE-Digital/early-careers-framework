# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_appropriate_body") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_appropriate_body }
    let(:factory_class) { AppropriateBody }
  end
end

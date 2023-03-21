# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_email") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_email }
    let(:factory_class) { Email }
  end
end

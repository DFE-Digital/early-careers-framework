# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_provider_relationship") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_provider_relationship }
    let(:factory_class) { ProviderRelationship }
  end
end

# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_lead_provider_cip") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_lead_provider_cip }
    let(:factory_class) { LeadProviderCip }
  end
end

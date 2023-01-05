# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_lead_provider") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_lead_provider }
    let(:factory_class) { LeadProvider }
  end
end

# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_npq_lead_provider_factory") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_npq_lead_provider }
    let(:factory_class) { NPQLeadProvider }
  end
end

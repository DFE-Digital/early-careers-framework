# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_gdpr_request") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_gdpr_request }
    let(:factory_class) { GDPRRequest }
  end
end

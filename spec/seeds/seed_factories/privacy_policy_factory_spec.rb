# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_privacy_policy") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_privacy_policy }
    let(:factory_class) { PrivacyPolicy }
  end
end

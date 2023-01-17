# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_nomination_email") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_nomination_email }
    let(:factory_class) { NominationEmail }
  end
end

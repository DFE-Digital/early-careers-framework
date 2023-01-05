# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_school_local_authority_factory") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_school_local_authority }
    let(:factory_class) { SchoolLocalAuthority }
  end
end

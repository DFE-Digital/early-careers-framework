# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_user") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_finance_schedule }
    let(:factory_class) { Finance::Schedule }
  end
end

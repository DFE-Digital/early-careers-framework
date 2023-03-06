# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_finance_milestone") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_finance_milestone }
    let(:factory_class) { Finance::Milestone }
  end
end

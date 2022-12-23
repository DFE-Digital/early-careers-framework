# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_npq_application") do
  let(:factory_name) { :seed_npq_application }

  it_behaves_like("a seed factory") do
    let(:factory_class) { NPQApplication }
  end

  describe "traits" do
    context "when company is set" do
      let(:object) { create(factory_name, :company, :valid) }

      it("creates a valid object")        { expect(object).to(be_valid) }
      it("persists the object")           { expect(object).to(be_persisted) }
      it("sets works_in_school as false") { expect(object.works_in_school).to(be(false)) }
    end

    context "when childcare is set" do
      let(:object) { create(factory_name, :company, :valid) }

      it("creates a valid object")        { expect(object).to(be_valid) }
      it("persists the object")           { expect(object).to(be_persisted) }
      it("sets works_in_school as false") { expect(object.works_in_school).to(be(false)) }
    end
  end
end

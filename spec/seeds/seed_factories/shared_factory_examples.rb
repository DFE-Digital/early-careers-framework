# frozen_string_literal: true

RSpec.shared_examples("a seed factory") do
  describe "without traits" do
    let(:object) { build(factory_name) }

    it("builds an object") do
      expect(object).to(be_a(factory_class))
    end
  end

  describe ":valid" do
    let(:object) { create(factory_name, :valid) }

    it("creates a valid object") { expect(object).to(be_valid) }
    it("persists the object")    { expect(object).to(be_persisted) }
  end

  describe "logging" do
    it "logs that it's been called" do
      allow(Rails.logger).to receive(:debug).with(any_args).and_return(true)

      build(factory_name)

      expect(Rails.logger).to have_received(:debug).once
    end
  end
end

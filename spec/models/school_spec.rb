require "rails_helper"

RSpec.describe School, type: :model do
  describe "School" do
    it "can be created" do
      expect {
        School.create(urn: "TEST URN", name: "Test school", address: "Test Address")
      }.to change { School.count }.by(1)
    end

    it { is_expected.to have_one(:partnership) }
    it { is_expected.to have_one(:lead_provider).through(:partnership) }
  end
end

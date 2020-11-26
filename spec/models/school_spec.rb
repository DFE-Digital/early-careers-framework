require "rails_helper"

RSpec.describe School, type: :model do
  describe "School" do
    it "can be created" do
      expect {
        School.create(urn: "TEST URN", name: "Test school", address: "Test Address")
      }.to change { School.count }.by(1)
    end

    it "can have a partnership" do
      school = School.create!(urn: "TEST URN", name: "Test school", address: "Test Address")
      partnership = FactoryBot.create(:partnership_with_provider, school: school)

      expect(school.lead_provider).to eq(partnership.lead_provider)
    end
  end
end

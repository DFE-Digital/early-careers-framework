require "rails_helper"

RSpec.describe LeadProvider, type: :model do
  it "can be created" do
    expect {
      LeadProvider.create(name: "Test Lead Provider")
    }.to change { LeadProvider.count }.by(1)
  end

  it "can have a partnership" do
    lead_provider = LeadProvider.create!(name: "Test Lead Provider")
    partnership = FactoryBot.create(:partnership_with_school, lead_provider: lead_provider)

    expect(lead_provider.schools.count).to eq(1)
    expect(lead_provider.schools).to include(partnership.school)
  end
end

require "rails_helper"

RSpec.describe LeadProvider, type: :model do
  it "can be created" do
    expect {
      LeadProvider.create(name: "Test Lead Provider")
    }.to change { LeadProvider.count }.by(1)
  end

  it { is_expected.to have_many(:partnerships) }
  it { is_expected.to have_many(:schools).through(:partnerships) }
end

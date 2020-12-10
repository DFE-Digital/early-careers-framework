# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partnership, type: :model do
  it "can be unconfirmed" do
    partnership = Partnership.create!(
      school: FactoryBot.create(:school),
      lead_provider: FactoryBot.create(:lead_provider),
    )
    expect(partnership.confirmed?).to be_falsey
  end

  it "can be confirmed" do
    partnership = Partnership.create!(
      school: FactoryBot.create(:school),
      lead_provider: FactoryBot.create(:lead_provider),
    )

    partnership.confirm
    expect(partnership.confirmed?).to be_truthy

    database_partnership = Partnership.first
    expect(database_partnership.confirmed?).to be_truthy
  end
end

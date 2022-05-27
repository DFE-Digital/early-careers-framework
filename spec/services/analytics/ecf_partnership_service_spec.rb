# frozen_string_literal: true

describe 'Analytics::ECFPartnershipService' do
  let(:partnership) { create(:partnership) }

  it "saves a new record" do
    analytics_record = Analytics::ECFPartnership.find_by(partnership_id: partnership.id)
    expect(analytics_record).to be_nil

    Analytics::ECFPartnershipService.upsert_record(partnership)

    analytics_record = Analytics::ECFPartnership.find_by(partnership_id: partnership.id)
    expect(analytics_record).to be_present
  end

  it "updates an existing record" do
    analytics_record = Analytics::ECFPartnership.find_by(partnership_id: partnership.id)
    Analytics::ECFPartnershipService.upsert_record(partnership)

    partnership.update!(pending: true)
    Analytics::ECFPartnershipService.upsert_record(partnership)

    analytics_record = Analytics::ECFPartnership.find_by(partnership_id: partnership.id)
    expect(analytics_record.pending).to be_truthy
  end
end

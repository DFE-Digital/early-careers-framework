# frozen_string_literal: true

describe Analytics::ECFAppropriateBodyService do
  let(:appropriate_body) { create(:appropriate_body_local_authority) }

  it "saves a new record" do
    expect {
      described_class.upsert_record(appropriate_body)
    }.to change { Analytics::ECFAppropriateBody.count }.by(1)
  end

  it "updates an existing record" do
    described_class.upsert_record(appropriate_body)

    analytics_record = Analytics::ECFAppropriateBody.find_by(appropriate_body_id: appropriate_body.id)
    expect(analytics_record).to be_present

    appropriate_body.update!(name: "Crispy Bacon")
    described_class.upsert_record(appropriate_body)

    expect(analytics_record.reload.name).to eq "Crispy Bacon"
  end
end

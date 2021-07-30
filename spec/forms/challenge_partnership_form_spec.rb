# frozen_string_literal: true

RSpec.describe ChallengePartnershipForm, type: :model do
  describe "validations" do
    it do
      is_expected.to validate_presence_of(:challenge_reason)
                       .with_message("Select a reason why you think this confirmation is incorrect")
    end
  end

  describe "#challenge!" do
    let(:partnership) { create :partnership }
    let(:reason) { described_class.new.challenge_reason_options.sample.id }

    subject { described_class.new(partnership_id: partnership.id, challenge_reason: reason) }

    it "calls Partnerships::Challenge" do
      expect(Partnerships::Challenge).to receive(:call).with(partnership, reason)
      subject.challenge!
    end
  end

  describe "#partnership" do
    let!(:correct_partnership) { create(:partnership) }
    let!(:incorrect_partnership) { create(:partnership) }
    subject { described_class.new(partnership_id: correct_partnership.id) }

    it "returns the correct partnership" do
      expect(subject.partnership).to eql correct_partnership
    end
  end

  describe "#lead_provider_name" do
    let!(:partnership) { create(:partnership) }
    let!(:incorrect_lead_provider) { create(:lead_provider, name: "wrong name") }
    let(:correct_name) { partnership.lead_provider.name }
    subject { described_class.new(partnership_id: partnership.id) }

    it "returns the correct lead provider name" do
      expect(subject.lead_provider_name).to eql correct_name
    end
  end

  describe "#delivery_partner_name" do
    let!(:partnership) { create(:partnership) }
    let!(:incorrect_lead_provider) { create(:delivery_partner, name: "wrong name") }
    let(:correct_name) { partnership.delivery_partner.name }
    subject { described_class.new(partnership_id: partnership.id) }

    it "returns the correct delivery partner name" do
      expect(subject.delivery_partner_name).to eql correct_name
    end
  end
end

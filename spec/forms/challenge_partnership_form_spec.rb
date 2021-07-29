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
end

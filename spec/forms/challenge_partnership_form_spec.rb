# frozen_string_literal: true

RSpec.describe ChallengePartnershipForm, type: :model do
  describe "validations" do
    it do
      is_expected.to validate_presence_of(:challenge_reason)
        .with_message("Select a reason why you think this confirmation is incorrect")
    end
  end

  describe "#challenge!" do
    let(:lead_provider) { create :lead_provider }
    let!(:lead_provider_profiles) { create_list(:lead_provider_profile, rand(2..3), lead_provider: lead_provider) }
    let(:partnership) { create :partnership, lead_provider: lead_provider }
    let(:reason) { described_class.new.challenge_reason_options.sample.id }

    subject { described_class.new(partnership: partnership, challenge_reason: reason) }

    it "marks given partnership as challenged" do
      expect { subject.challenge! }.to change { partnership.reload.challenged? }.to true
    end

    it "schedules partnership challenged emails" do
      subject.challenge!

      lead_provider_profiles.each do |lp_profile|
        expect(LeadProviderMailer).to delay_email_delivery_of(:partnership_challenged_email)
          .with(user: lp_profile.user, partnership: partnership)
      end
    end
  end
end

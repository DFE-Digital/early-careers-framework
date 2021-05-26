# frozen_string_literal: true

RSpec.describe LeadProviders::Partnerships::ChallengedBanner, type: :view_component do
  let(:component) { described_class.new(partnership: partnership) }

  context "when partnership is not challenged" do
    let(:partnership) { create :partnership }

    it { is_expected.not_to render }
  end

  context "when partnership is challenged" do
    let(:partnership) { create :partnership, :challenged }

    it "renders expected notification banner" do
      banner = rendered.css(".govuk-notification-banner")

      expect(banner)
        .to have_selector(".govuk-notification-banner__header", text: "Important")
        .and have_content(t(".header"))
        .and have_content(t(".content", reason: t(partnership.challenge_reason, scope: "partnerships.challenge_reasons")))
    end
  end
end

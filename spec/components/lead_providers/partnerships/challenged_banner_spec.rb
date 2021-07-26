# frozen_string_literal: true

RSpec.describe LeadProviders::Partnerships::ChallengedBanner, type: :view_component do
  let(:component) { described_class.new(partnership: partnership) }

  let(:partnership) { create :partnership, :challenged }

  it "renders expected notification banner" do
    banner = rendered.css(".govuk-notification-banner")

    expect(banner).to have_selector(".govuk-notification-banner__header", text: "Important")
    expect(banner).to have_content(t(".header"))
    expect(banner).to have_content(t(".content", reason: t(partnership.challenge_reason, scope: "partnerships.challenge_reasons")))
  end
end

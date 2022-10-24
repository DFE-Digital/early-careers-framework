# frozen_string_literal: true

RSpec.describe LeadProviders::Partnerships::ChallengedBanner, type: :component do
  let(:component) { described_class.new(partnership:) }

  let(:partnership) { create :partnership, :challenged }
  subject { render_inline(component) }

  it "renders expected notification banner" do
    banner = subject.css(".govuk-notification-banner")

    expect(banner).to have_selector(".govuk-notification-banner__header", text: "Important")
    expect(banner).to have_content(I18n.t("#{described_class.translation_key}.header"))
    expect(banner).to have_content(I18n.t("#{described_class.translation_key}.content", reason: I18n.t(partnership.challenge_reason, scope: "partnerships.challenge_reasons")))
  end
end

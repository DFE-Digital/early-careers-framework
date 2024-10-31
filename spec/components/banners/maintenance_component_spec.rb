# frozen_string_literal: true

require "rails_helper"

RSpec.describe Banners::MaintenanceComponent, type: :component do
  let(:maintenance_window) { Time.zone.local(2050, 11, 27, 19)..Time.zone.local(2050, 11, 27, 21) }
  let(:component) { described_class.new }

  before do
    FeatureFlag.activate(:maintenance_banner)
    stub_const("Banners::MaintenanceComponent::MAINTENANCE_WINDOW", maintenance_window)
  end

  subject do
    render_inline(component)
    page
  end

  it { is_expected.to have_css(".govuk-width-container") }
  it { is_expected.to have_css("h2", text: "Important") }
  it { is_expected.to have_css(".govuk-notification-banner__heading", text: "This service will be unavailable from 7pm to 9pm on 27 November.") }
  it { is_expected.to have_link("Dismiss", href: maintenance_banner_dismiss_path) }

  context "when the maintenance window spans multiple days" do
    let(:maintenance_window) { Time.zone.local(2050, 11, 27, 19)..Time.zone.local(2050, 11, 28, 21) }

    it { is_expected.to have_css(".govuk-notification-banner__heading", text: "This service will be unavailable from 7pm on 27 November to 9pm on 28 November.") }
  end

  describe "#render?" do
    subject { component }

    it { is_expected.to render }

    context "when the maintenance window has ended" do
      let(:maintenance_window) { 2.days.ago..1.minute.ago }

      it { is_expected.not_to render }
    end

    context "when the maintenance banner feature flag is not active" do
      before { FeatureFlag.deactivate(:maintenance_banner) }

      it { is_expected.not_to render }
    end
  end
end

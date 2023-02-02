# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderMailer, type: :mailer do
  describe "#welcome_email_confirmation" do
    let(:lead_provider) { build(:lead_provider) }
    let(:user) { create(:user, :lead_provider) }
    let(:start_url) { "https://ecf-dev.london.cloudapps" }

    let(:nomination_confirmation_email) do
      LeadProviderMailer.welcome_email(
        { user:, lead_provider_name: lead_provider.name, start_url: },
      ).deliver_now
    end

    it "renders the right headers" do
      expect(nomination_confirmation_email.to).to eq([user.email])
      expect(nomination_confirmation_email.from).to eq(["mail@example.com"])
    end
  end

  describe "#partnership_challenged_email" do
    let(:user) { create :user }
    let(:partnership) { create :partnership, :challenged }

    let(:nomination_confirmation_email) do
      LeadProviderMailer.partnership_challenged_email(
        {
          user:,
          partnership:,
        },
      ).deliver_now
    end

    it "renders the right headers" do
      expect(nomination_confirmation_email.to).to eq([user.email])
      expect(nomination_confirmation_email.from).to eq(["mail@example.com"])
    end
  end

  describe "#programme_changed_email" do
    let(:user) { create :user }
    let(:partnership) { create :partnership, :challenged }
    let(:cohort_year) { 2022 }
    let(:what_changes_choice) { "change_lead_provider" }

    let(:programme_changed_email) do
      LeadProviderMailer.programme_changed_email(
        {
          user:,
          partnership:,
          cohort_year:,
          what_changes_choice:,
        },
      ).deliver_now
    end

    it "renders the right headers" do
      expect(programme_changed_email.to).to eq([user.email])
      expect(programme_changed_email.from).to eq(["mail@example.com"])
    end
  end
end

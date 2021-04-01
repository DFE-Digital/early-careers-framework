# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominationEmail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
  end

  describe "expired email" do
    let(:expired_nomination_email) { create(:nomination_email, :expired_nomination_email) }

    it "shows as expired once it goes beyond expiration date" do
      expect(expired_nomination_email.expired?).to eq true
    end
  end
end

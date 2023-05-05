# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  let(:user) { create(:user, :admin) }
  let(:sign_in_link) { "http://www.example.com/users/sign_in" }

  describe "#account_created_email" do
    let(:account_created_email) do
      AdminMailer.with(admin: user, url: sign_in_link).account_created_email.deliver_now
    end

    it "renders the right headers" do
      expect(account_created_email.to).to eq([user.email])
      expect(account_created_email.from).to eq(["mail@example.com"])
    end
  end
end

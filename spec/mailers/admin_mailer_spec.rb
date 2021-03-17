# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  let(:user) { create(:user, :admin) }
  let(:sign_in_link) { "http://www.example.com/users/sign_in" }

  describe "#account_created_email" do
    let(:account_created_email) do
      AdminMailer.account_created_email(user, sign_in_link)
    end

    it "renders the right headers" do
      expect(account_created_email.to).to eq([user.email])
      expect(account_created_email.from).to eq(["mail@example.com"])
    end
  end
end

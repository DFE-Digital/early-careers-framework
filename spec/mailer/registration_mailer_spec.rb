require "rails_helper"

RSpec.describe RegistrationMailer, type: :mailer do
  describe "send_registration_email" do
    it "sets the correct email addresses" do
      mail = RegistrationMailer.send_registration_email("to@example.org", "John Doe", "Confirm email url")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["mail@example.com"])
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyEmailValidator do
  with_model :user do
    table do |t|
      t.string :email
    end

    model do
      validates :email, notify_email: true
    end
  end

  # rubocop:disable Style/AsciiComments
  # Test cases from https://github.com/alphagov/notifications-utils/blob/2432e1881cf7a5005a8d69c2ddc1597add96acc3/tests/test_recipient_validation.py
  # The following valid emails addresses are not accepted: japanese-info@例え.テスト, info@german-financial-services.vermögensberatung
  # This is because we do not transform to punycode
  # rubocop:enable Style/AsciiComments
  it "correctly identifies valid email addresses" do
    valid_email_addresses = %w[email@domain.com email@domain.COM firstname.lastname@domain.com firstname.o\'lastname@domain.com email@subdomain.domain.com firstname+lastname@domain.com 1234567890@domain.com email@domain-one.com _______@domain.com email@domain.name email@domain.superlongtld email@domain.co.jp firstname-lastname@domain.com info@german-financial-services.reallylongarbitrarytldthatiswaytoohugejustincase email@double--hyphen.com]
    valid_email_addresses.each do |email|
      expect(User.new(email: email)).to be_valid
    end
  end

  it "correctly identifies invalid email addresses" do
    invalid_email_addresses = [
      "email@123.123.123.123",
      "email@[123.123.123.123]",
      "plainaddress",
      "@no-local-part.com",
      "Outlook Contact <outlook-contact@domain.com>",
      "no-at.domain.com",
      "no-tld@domain",
      ";beginning-semicolon@domain.co.uk",
      "middle-semicolon@domain.co;uk",
      "trailing-semicolon@domain.com;",
      '"email+leading-quotes@domain.com',
      'email+middle"-quotes@domain.com',
      '"quoted-local-part"@domain.com',
      '"quoted@domain.com"',
      "lots-of-dots@domain..gov..uk",
      "two-dots..in-local@domain.com",
      "multiple@domains@domain.com",
      "spaces in local@domain.com",
      "spaces-in-domain@dom ain.com",
      "underscores-in-domain@dom_ain.com",
      "pipe-in-domain@example.com|gov.uk",
      "comma,in-local@gov.uk",
      "comma-in-domain@domain,gov.uk",
      "pound-sign-in-local£@domain.com",
      "local-with-’-apostrophe@domain.com",
      "local-with-”-quotes@domain.com",
      "domain-starts-with-a-dot@.domain.com",
      "brackets(in)local@domain.com",
      "email-too-long-#{'a' * 320}@example.com",
      "incorrect-punycode@xn---something.com",
    ]
    invalid_email_addresses.each do |email|
      expect(User.new(email: email)).not_to be_valid
    end
  end
end

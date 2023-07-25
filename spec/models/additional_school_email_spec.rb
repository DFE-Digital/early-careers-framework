# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdditionalSchoolEmail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
  end

  describe "whitespace stripping" do
    let(:additional_school_email) { build(:additional_school_email, email_address: " \tgordo@example.com \n ") }

    it "strips whitespace from :email_address" do
      additional_school_email.valid?
      expect(additional_school_email.email_address).to eq "gordo@example.com"
    end
  end
end

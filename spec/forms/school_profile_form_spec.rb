# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolProfileForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:urn).with_message("Enter a school URN") }

    context "when urn does not belong to a school" do
      subject(:form) { SchoolProfileForm.new(urn: "123456") }

      it "is invalid" do
        expect(form.valid?).to be_falsey
        expect(form.errors.full_messages[0]).to include("No school matched that URN")
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ValidationDataForm, type: :model do
  subject(:form) { described_class.new(participant_profile_id: participant_profile.id) }
  let(:participant_profile) { create :ect_participant_profile }

  describe "#formatted_nino" do
    it "returns a normalised version of the entered nino" do
      form.nino = "AB 12 34 56 C"
      expect(form.formatted_nino).to eq "AB123456C"
    end
  end

  describe "validations" do
    context "when :full_name step" do
      it { is_expected.to validate_presence_of(:full_name).on(:full_name) }
    end

    context "when :trn step" do
      it { is_expected.to validate_presence_of(:trn).on(:trn) }
    end

    context "when :date_of_birth step" do
      it { is_expected.to validate_presence_of(:date_of_birth).on(:date_of_birth) }

      it "checks that the date_of_birth is not in the future" do
        form.date_of_birth = 1.day.from_now
        expect(form.valid?(:date_of_birth)).to be false
        expect(form.errors[:date_of_birth]).to be_present
      end

      it "checks that the date_of_birth is not in the future" do
        form.date_of_birth = 1.day.from_now
        expect(form.valid?(:date_of_birth)).to be false
        expect(form.errors[:date_of_birth]).to be_present
      end

      it "checks that the date_of_birth is not before 1900" do
        form.date_of_birth = Date.new(1899, 12, 31)
        expect(form.valid?(:date_of_birth)).to be false
        expect(form.errors[:date_of_birth]).to be_present
      end

      it "checks that the date_of_birth is not more recent than 18 years ago" do
        form.date_of_birth = ((18 * 12) - 1).months.ago
        expect(form.valid?(:date_of_birth)).to be false
        expect(form.errors[:date_of_birth]).to be_present
      end
    end

    context "when :nino step" do
      it { is_expected.not_to validate_presence_of(:nino).on(:nino) }

      it "checks that the national insurance number is correctly formatted" do
        form.nino = "121cx"
        expect(form.valid?(:nino)).to be false
        expect(form.errors[:nino]).to be_present
      end
    end
  end
end

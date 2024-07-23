# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::TransferOutForm, type: :model do
  let(:end_date) { { 3 => 11, 2 => 11, 1 => 2021 } }
  subject(:form) { described_class.new(end_date:) }

  describe "validations" do
    it "checks the date is present" do
      form.end_date = nil
      expect(form.valid?(:end_date)).to be false
      expect(form.errors[:end_date]).to eq([I18n.t("errors.end_date.blank")])
    end

    it "checks the year is valid" do
      form.end_date = { 3 => 11, 2 => 11, 1 => 22 }
      expect(form.valid?(:end_date)).to be false
      expect(form.errors[:end_date]).to eq([I18n.t("errors.end_date.invalid")])
    end

    it "handles argument errors on end_date" do
      form.end_date = { 3 => 22, 2 => 111, 1 => 2222 }
      expect(form.valid?(:end_date)).to be false
      expect(form.errors[:end_date]).to eq([I18n.t("errors.end_date.invalid")])
    end
  end
end

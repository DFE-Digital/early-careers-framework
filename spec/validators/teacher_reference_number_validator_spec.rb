# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherReferenceNumberValidator do
  with_model :teacher do
    table do |t|
      t.string :trn
    end

    model do
      validates :trn, teacher_reference_number: true
    end
  end

  it "correctly identifies valid TRNs" do
    valid_trns = ["12345", "RP99/12345", "RP / 1234567", "  R P 99 / 1234", "ZZ-123445 "]

    valid_trns.each do |trn|
      expect(Teacher.new(trn:)).to be_valid
    end
  end

  it "correctly identifies invalid TRNs" do
    invalid_trns = {
      too_short: "1234",
      too_long: "RP99/123457",
      invalid: "No-numbers",
      blank: "",
    }

    invalid_trns.each do |k, v|
      teacher = Teacher.new(trn: v)
      expect(teacher).not_to be_valid
      expect(teacher.errors[:trn]).to include(I18n.t(k, scope: "errors.teacher_reference_number"))
    end
  end
end

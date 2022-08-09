# frozen_string_literal: true

require "rails_helper"

RSpec.describe NationalInsuranceNumberValidator, type: :model do
  with_model :participant do
    table do |t|
      t.string :nino
    end

    model do
      validates :nino, national_insurance_number: true
    end
  end

  def valid_ninos
    [
      "AB123456A",
      "AB123456   A",
      "AB 12 34 56 A",
      "A B 1 2 3 4 5 6 A",
    ]
  end

  def invalid_ninos
    %w[DA123456A
       FA123456A
       IA123456A
       QA123456A
       UA123456A
       VA123456A
       AD123456A
       AF123456A
       AI123456A
       AQ123456A
       AU123456A
       AV123456A
       AO123456A
       BG123456A
       GB123456A
       KN123456A
       NK123456A
       NT123456A
       TN123456A
       ZZ123456A]
  end

  subject { Participant.new }

  it { is_expected.to allow_values(*valid_ninos).for(:nino) }
  it { is_expected.not_to allow_values(*invalid_ninos).for(:nino) }

  it "add specific error message to the record for blank ninos" do
    participant = Participant.new(nino: "")

    expect(participant).not_to be_valid
    expect(participant.errors[:nino]).to include(I18n.t(:blank, scope: "errors.national_insurance_number"))
  end

  it "add specific error message to the record for invalid ninos" do
    participant = Participant.new(nino: "QQ123456A")

    expect(participant).not_to be_valid
    expect(participant.errors[:nino]).to include(I18n.t(:invalid, scope: "errors.national_insurance_number"))
  end
end

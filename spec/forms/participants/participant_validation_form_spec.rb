# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ParticipantValidationForm, type: :model do
  subject(:form) { described_class.new }

  describe "do_you_know_your_trn validations" do
    context "when a valid choice is made" do
      it "returns true" do
        form.do_you_know_your_trn_choice = form.trn_choices.map(&:id).sample
        expect(form.valid?(:do_you_know_your_trn)).to be true
        expect(form.errors).to be_empty
      end
    end

    context "when no choice has been made" do
      it "returns false" do
        expect(form.valid?(:do_you_know_your_trn)).to be false
        expect(form.errors).to include :do_you_know_your_trn_choice
      end
    end

    context "when an invalid choice has been made" do
      it "returns false" do
        form.do_you_know_your_trn_choice = :banana
        expect(form.valid?(:do_you_know_your_trn)).to be false
        expect(form.errors).to include :do_you_know_your_trn_choice
      end
    end
  end

  describe "name_change_choice validations" do
    context "when a valid choice is made" do
      it "returns true" do
        form.have_you_changed_your_name_choice = form.name_change_choices.map(&:id).sample
        expect(form.valid?(:have_you_changed_your_name)).to be true
        expect(form.errors).to be_empty
      end
    end

    context "when no choice has been made" do
      it "returns false" do
        expect(form.valid?(:have_you_changed_your_name)).to be false
        expect(form.errors).to include :have_you_changed_your_name_choice
      end
    end

    context "when an invalid choice has been made" do
      it "returns false" do
        form.have_you_changed_your_name_choice = :pineapple
        expect(form.valid?(:have_you_changed_your_name)).to be false
        expect(form.errors).to include :have_you_changed_your_name_choice
      end
    end
  end

  describe "confirm_updated_record validations" do
    context "when a valid choice is made" do
      it "returns true" do
        form.updated_record_choice = form.updated_record_choices.map(&:id).sample
        expect(form.valid?(:confirm_updated_record)).to be true
        expect(form.errors).to be_empty
      end
    end

    context "when no choice has been made" do
      it "returns false" do
        expect(form.valid?(:confirm_updated_record)).to be false
        expect(form.errors).to include :updated_record_choice
      end
    end

    context "when an invalid choice has been made" do
      it "returns false" do
        form.updated_record_choice = :grape
        expect(form.valid?(:confirm_updated_record)).to be false
        expect(form.errors).to include :updated_record_choice
      end
    end
  end

  describe "name_not_updated validations" do
    context "when a valid choice is made" do
      it "returns true" do
        form.name_not_updated_choice = form.name_not_updated_choices.map(&:id).sample
        expect(form.valid?(:name_not_updated)).to be true
        expect(form.errors).to be_empty
      end
    end

    context "when no choice has been made" do
      it "returns false" do
        expect(form.valid?(:name_not_updated)).to be false
        expect(form.errors).to include :name_not_updated_choice
      end
    end

    context "when an invalid choice has been made" do
      it "returns false" do
        form.name_not_updated_choice = :grape
        expect(form.valid?(:name_not_updated)).to be false
        expect(form.errors).to include :name_not_updated_choice
      end
    end
  end

  describe "teacher_details validations" do
    let(:teacher_details) { { trn: "1234567", name: "Wilma Flintstone", date_of_birth: "1996-4-17", national_insurance_number: "AB123456C" } }
    subject(:form) { described_class.new(teacher_details) }

    context "when all fields are valid" do
      it "returns true" do
        expect(form.valid?(:tell_us_your_details)).to be true
      end
    end

    context "when trn is not supplied" do
      it "returns false" do
        form.trn = nil
        expect(form.valid?(:tell_us_your_details)).to be false
        expect(form.errors).to include :trn
      end
    end

    context "when trn has leading/trailing whiitespace" do
      it "strips whitespace and validates" do
        form.trn = "   1234567  \t\n"
        expect(form.valid?(:tell_us_your_details)).to be true
      end
    end

    context "when name is not supplied" do
      it "returns false" do
        form.name = nil
        expect(form.valid?(:tell_us_your_details)).to be false
        expect(form.errors).to include :name
      end
    end

    context "when date_of_birth is not supplied" do
      it "returns false" do
        form.date_of_birth = nil
        expect(form.valid?(:tell_us_your_details)).to be false
        expect(form.errors).to include :date_of_birth
      end
    end

    context "when national_insurance_number is not supplied" do
      it "returns true" do
        form.national_insurance_number = nil
        expect(form.valid?(:tell_us_your_details)).to be true
        expect(form.errors).to be_empty
      end
    end

    context "when national_insurance_number is in an incorrect format" do
      it "returns false" do
        form.national_insurance_number = "A 12 VV"
        expect(form.valid?(:tell_us_your_details)).to be false
        expect(form.errors).to include :national_insurance_number
      end
    end

    context "when national_insurance_number has leading/trailing whiitespace" do
      it "strips whitespace and validates" do
        form.national_insurance_number = "   AB123456C  \t\n"
        expect(form.valid?(:tell_us_your_details)).to be true
      end
    end
  end

  describe "#attributes" do
    it "returns a hash of the attribute data" do
      values = {
        step: :my_step,
        do_you_know_your_trn_choice: form.trn_choices.map(&:id).sample,
        have_you_changed_your_name_choice: form.name_change_choices.map(&:id).sample,
        updated_record_choice: form.updated_record_choices.map(&:id).sample,
        name_not_updated_choice: form.name_not_updated_choices.map(&:id).sample,
        trn: "1234567",
        name: "Ted Smith",
        date_of_birth: Date.new(1993, 6, 15),
        national_insurance_number: "AB123456C",
        validation_attempts: 1,
      }
      form = described_class.new(values)
      expect(form.attributes).to match(values)
    end

    context "when participant details have extraneous whitespace" do
      it "squishes the whitespace" do
        values = {
          trn: "   1231222  \t",
          name: "    Shiela\n\t Smith    \n",
          national_insurance_number: "    AW  23  44 44  A\t\n ",
        }
        form = described_class.new(values)
        attributes = form.attributes
        expect(attributes[:trn]).to eq "1231222"
        expect(attributes[:name]).to eq "Shiela Smith"
        expect(attributes[:national_insurance_number]).to eq "AW 23 44 44 A"
      end
    end
  end

  describe "#trn_choices" do
    it "provides options for the teacher reference number choice" do
      expect(form.trn_choices.map(&:id)).to match_array %w[yes no i_do_not_have]
    end
  end

  describe "#name_change_choices" do
    it "provides options for the name changed choice" do
      expect(form.name_change_choices.map(&:id)).to match_array %w[yes no]
    end
  end

  describe "#updated_record_choices" do
    it "provides options for the name record updated choice" do
      expect(form.updated_record_choices.map(&:id)).to match_array %w[yes no i_do_not_know]
    end
  end

  describe "#name_not_updated_choices" do
    it "provides options for the name not updated choice" do
      expect(form.name_not_updated_choices.map(&:id)).to match_array %w[register_previous_name update_name]
    end
  end

  describe "#pretty_date_of_birth" do
    it "formats the date of birth correctly" do
      form.date_of_birth = "1989-3-22"
      expect(form.pretty_date_of_birth).to eq "22 March 1989"
    end
  end
end

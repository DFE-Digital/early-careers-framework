# frozen_string_literal: true

require "rails_helper"

RSpec.xdescribe Schools::AddParticipants::TransferWizard, type: :model do
  let(:school_cohort) { create(:school_cohort) }
  let(:user) { create(:user) }

  subject(:form) { described_class.new }

  describe "full_name" do
    context "when a name is entered" do
      it "returns true" do
        form.full_name = "Brad Binder"
        expect(form.valid?(:full_name)).to be true
        expect(form.errors[:full_name]).to be_empty
      end
    end

    context "when no name is entered" do
      it "returns false" do
        form.full_name = ""
        expect(form.valid?(:full_name)).to be false
        expect(form.errors[:full_name]).to include "Enter a full name"
      end
    end
  end

  describe "trn" do
    context "when a valid trn is entered" do
      it "returns true" do
        form.trn = 1_234_567
        expect(form.valid?(:trn)).to be true
        expect(form.errors[:trn]).to be_empty
      end
    end

    context "when no trn is entered" do
      it "returns false" do
        form.trn = ""
        expect(form.valid?(:trn)).to be false
        expect(form.errors[:trn]).to include "Enter the teacher reference number (TRN)"
      end
    end

    context "when incorrect length TRN is entered" do
      it "returns false when TRN is less than 5 digits" do
        form.trn = "1234"
        expect(form.valid?(:trn)).to be false
        expect(form.errors[:trn]).to include "Teacher reference number must include at least 5 digits"
      end
    end

    context "when incorrect length TRN is entered" do
      it "returns false when TRN is more than 7 digits" do
        form.trn = "12345678"
        expect(form.valid?(:trn)).to be false
        expect(form.errors[:trn]).to include "Teacher reference number cannot include more than 7 digits"
      end
    end

    context "when trn contains no digits" do
      it "returns false" do
        form.trn = "ABCD/EFGH"
        expect(form.valid?(:trn)).to be false
        expect(form.errors[:trn]).to include "Teacher reference number must include at least 5 digits"
      end
    end
  end

  describe "dob" do
    context "when valid date of birth is entered" do
      it "returns true" do
        form.date_of_birth = { 3 => 31, 2 => 9, 1 => 1990 }
        expect(form.valid?(:dob)).to be true
        expect(form.errors[:date_of_birth]).to be_empty
      end
    end

    context "when no date of birth is entered" do
      it "returns false" do
        form.date_of_birth = nil
        expect(form.valid?(:dob)).to be false
        expect(form.errors[:date_of_birth]).to include "Enter date of birth"
      end
    end

    context "when date in future is entered" do
      it "returns false" do
        form.date_of_birth = { 3 => 31, 2 => 9, 1 => 2090 }
        expect(form.valid?(:dob)).to be false
        expect(form.errors[:date_of_birth]).to include "Date is in the future"
      end
    end

    context "when date is within past 18 years" do
      it "returns false" do
        ten_years_ago = Time.zone.today.year - 10
        form.date_of_birth = { 3 => 31, 2 => 9, 1 => ten_years_ago }
        expect(form.valid?(:dob)).to be false
        expect(form.errors[:date_of_birth]).to include "Invalid date of birth"
      end
    end
  end

  describe "start_date" do
    context "when valid start date is entered" do
      it "returns true" do
        form.start_date = { 3 => 31, 2 => 9, 1 => 2022 }
        expect(form.valid?(:teacher_start_date)).to be true
        expect(form.errors[:start_date]).to be_empty
      end
    end

    context "when no start_date is entered" do
      it "returns false" do
        form.start_date = nil
        expect(form.valid?(:teacher_start_date)).to be false
        expect(form.errors[:start_date]).to include "Enter start date"
      end
    end
  end

  describe "email" do
    context "when a valid email is entered" do
      it "returns true" do
        form.email = "jackmiller@example.com"
        expect(form.valid?(:email)).to be true
        expect(form.errors[:email]).to be_empty
      end
    end

    context "when a invalid email is entered" do
      it "returns false" do
        form.email = "jackmiller@"
        expect(form.valid?(:email)).to be false
        expect(form.errors[:email]).to include "Enter an email address in the correct format, like name@example.com"
      end
    end

    context "when a no email is entered" do
      it "returns false" do
        form.email = nil
        expect(form.valid?(:email)).to be false
        expect(form.errors[:email]).to include "Enter an email"
      end
    end
  end

  describe "mentor" do
    context "when a mentor is chosen" do
      it "returns true" do
        form.mentor_id = 123
        expect(form.valid?(:choose_mentor)).to be true
        expect(form.errors[:mentor_id]).to be_empty
      end
    end

    context "selects to assign mentor later" do
      it "returns true" do
        form.mentor_id = "later"
        expect(form.valid?(:choose_mentor)).to be true
        expect(form.valid?(:mentor)).to be true
        expect(form.errors[:mentor_id]).to be_empty
      end
    end

    context "no option selected" do
      it "returns false" do
        form.mentor_id = nil
        expect(form.valid?(:choose_mentor)).to be false
        expect(form.errors[:mentor_id]).to include "Select an option"
      end
    end
  end

  describe "schools programme choice" do
    context "select yes to choosing schools current programme" do
      it "returns true" do
        form.schools_current_programme_choice = "yes"
        expect(form.valid?(:schools_current_programme)).to be true
        expect(form.errors[:schools_current_programme_choice]).to be_empty
      end
    end

    context "select no to choosing schools current programme" do
      it "returns true" do
        form.schools_current_programme_choice = "no"
        expect(form.valid?(:schools_current_programme)).to be true
        expect(form.errors[:schools_current_programme_choice]).to be_empty
      end
    end

    context "no option selected" do
      it "returns false" do
        form.schools_current_programme_choice = nil
        expect(form.valid?(:schools_current_programme)).to be false
        expect(form.errors[:schools_current_programme_choice]).to include "Select if the participant will continue with your schools current training programme"
      end
    end
  end

  describe "teachers programme choice" do
    context "select yes to choosing teachers current programme" do
      it "returns true" do
        form.teachers_current_programme_choice = "yes"
        expect(form.valid?(:teachers_current_programme)).to be true
        expect(form.errors[:teachers_current_programme_choice]).to be_empty
      end
    end

    context "select no to choosing teachers current programme" do
      it "returns true" do
        form.teachers_current_programme_choice = "no"
        expect(form.valid?(:teachers_current_programme)).to be true
        expect(form.errors[:teachers_current_programme_choice]).to be_empty
      end
    end

    context "no option selected" do
      it "returns false" do
        form.teachers_current_programme_choice = nil
        expect(form.valid?(:teachers_current_programme)).to be false
        expect(form.errors[:teachers_current_programme_choice]).to include "Select if the participant will continue with their current training programme"
      end
    end
  end

  describe "steps" do
    it "add the current step to the steps when set to nil" do
      form.steps = nil
      form.current_step = "full_name"
      form.update_steps
      expect(form.steps).to eq(%w[what_we_need full_name])
    end

    it "add the current step to the steps when set to nil" do
      form.steps = %w[what_we_need full_name trn dob email]
      form.current_step = "choose_mentor"
      form.update_steps
      expect(form.steps).to eq(%w[what_we_need full_name trn dob email choose_mentor])
    end

    it "correctly shows the previous page action" do
      form.steps = %w[what_we_need full_name trn]
      form.current_step = "dob"
      form.update_steps
      expect(form.previous_step).to eq(:trn)
      expect(form.steps).to eq(%w[what_we_need full_name trn])
    end

    context "sit has changed transferees details" do
      it "correctly shows the previous page action for multiple steps in " do
        form.steps = %w[what_we_need full_name trn cannot_find_their_details]
        form.current_step = "trn"
        form.update_steps
        form.current_step = "email"
        form.update_steps
        expect(form.previous_step).to eq(:trn)
        expect(form.steps).to eq(%w[what_we_need full_name trn cannot_find_their_details trn])
      end
    end
  end
end

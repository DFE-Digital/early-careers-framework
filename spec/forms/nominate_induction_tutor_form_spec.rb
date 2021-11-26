# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominateInductionTutorForm, type: :model do
  let(:nomination_email) { create(:nomination_email) }
  let(:token) { nomination_email.token }
  let(:school) { nomination_email.school }
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  describe "validations" do
    it { is_expected.to validate_presence_of(:full_name).with_message("Enter a full name").on(%i[full_name check_name]) }
    it { is_expected.to validate_presence_of(:email).with_message("Enter an email").on(%i[email create]) }

    it "validates that the email address is not in use by an ECT" do
      create(:ect_participant_profile, user: create(:user, email: email))
      form = NominateInductionTutorForm.new(token: token, full_name: name, email: email)
      expect(form.valid?(:email)).to be false
      expect(form.errors[:email].first).to eq("This email address is already in use")
      expect(form.email_already_taken?).to be_truthy
    end

    it "allows the email to be in use by a mentor" do
      create(:mentor_participant_profile, user: create(:user, email: email))

      form = NominateInductionTutorForm.new(token: token, full_name: name, email: email)
      expect(form).to be_valid
    end

    it "allows the email to be in use by an induction tutor" do
      create(:user, :induction_coordinator, full_name: name, email: email)
      form = NominateInductionTutorForm.new(token: token, full_name: name, email: email)
      expect(form).to be_valid
    end

    it "allows the email to be in use by a NPQ registrant" do
      npq_user = create(:user, full_name: name, email: email)
      create(:npq_participant_profile, user: npq_user)

      form = NominateInductionTutorForm.new(token: token, full_name: name, email: email)
      expect(form).to be_valid
    end

    it "validates that the name matches if the email matches an induction tutor" do
      create(:user, :induction_coordinator, full_name: "One Name", email: email)
      form = NominateInductionTutorForm.new(token: token, full_name: "Different Name", email: email)
      expect(form.valid?(:email)).to be false
      expect(form.errors[:full_name].first).to eq("The name you entered does not match our records")
      expect(form.name_different?).to be_truthy
    end
  end

  describe "#school" do
    context "from token accessor" do
      it "returns the correct school" do
        form = NominateInductionTutorForm.new(token: token)

        expect(form.school).to eql school
      end
    end

    context "from school_id accessor" do
      let(:school) { create(:school) }
      it "returns the correct school" do
        form = NominateInductionTutorForm.new(school_id: school.id)

        expect(form.school).to eql school
      end
    end
  end
end

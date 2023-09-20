# frozen_string_literal: true

require "rails_helper"

RSpec.describe EditInductionTutorForm, type: :model do
  let(:induction_tutor) { NewSeeds::Scenarios::Schools::School.new.build.with_an_induction_tutor(full_name: "Helen Bach").induction_tutor }
  let(:full_name) { "Bert Pancakes" }
  let(:email) { Faker::Internet.email }

  describe "validations" do
    let(:form) { described_class.new(full_name:, email:, induction_tutor:) }

    it { is_expected.to validate_presence_of(:email).with_message("Enter an email address") }
    it { is_expected.to validate_presence_of(:full_name).with_message("Enter a full name") }
    it { is_expected.to validate_presence_of(:induction_tutor).with_message("can't be blank") }

    context "when the first name provided is different to the existing one" do
      let(:full_name) { induction_tutor.full_name.split(" ").first.next }

      it "an error is added" do
        expect(form).not_to be_valid
        expect(form.errors[:full_name].first).to eq("not valid. It looks like a different person's name")
      end
    end

    context "when the first name provided matches the existing one" do
      let(:full_name) { induction_tutor.full_name.next }

      it "is valid" do
        form.valid?

        expect(form.errors[:full_name]).to be_blank
      end
    end

    context "when the email provided is in use by another user" do
      before do
        create(:mentor, user: create(:user, email:))
      end

      it "an error is added" do
        expect(form).not_to be_valid
        expect(form.errors[:email].first).to eq("not valid. A different user was registered with this email address.")
      end
    end

    context "when the email provided is one of the emails of the induction tutor" do
      before do
        create(:participant_identity, user: induction_tutor, email:)
      end

      it "is valid" do
        form.valid?

        expect(form.errors[:email]).to be_blank
      end
    end

    context "when the email provided is not in use by any registered person" do
      it "is valid" do
        form.valid?

        expect(form.errors[:email]).to be_blank
      end
    end
  end

  describe "#save" do
    subject { described_class.new(full_name:, email:, induction_tutor:) }

    context "when the form is invalid for any reason" do
      let(:full_name) { induction_tutor.full_name.split(" ").first.next }

      it "returns false" do
        expect(subject.save).to be_falsey
      end

      it "doesn't change SIT's name" do
        expect { subject.save }.not_to change { induction_tutor.full_name }
      end

      it "doesn't change SIT's email" do
        expect { subject.save }.not_to change { induction_tutor.email }
      end
    end

    context "when the form is valid" do
      let(:full_name) { induction_tutor.full_name.next }

      it "returns true" do
        expect(subject.save).to be_truthy
      end

      it "updates SIT's name" do
        expect { subject.save }.to change { induction_tutor.full_name }.from(induction_tutor.full_name).to(full_name)
      end

      it "updates SIT's email" do
        expect { subject.save }.to change { induction_tutor.email }.from(induction_tutor.email).to(email)
      end
    end
  end
end

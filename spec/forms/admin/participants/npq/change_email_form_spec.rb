# frozen_string_literal: true

RSpec.describe Admin::Participants::NPQ::ChangeEmailForm, type: :model do
  let(:new_email) { "roger.test@something.org" }
  let(:user) { build(:user) }
  subject { described_class.new(user) }

  describe "validation" do
    it { is_expected.to validate_presence_of(:email) }

    context "when the email address is already taken" do
      let!(:original) { create(:user, email: new_email) }

      it "prevents another user from have that email address set" do
        user.email = new_email

        expect(user).not_to be_valid
        expect(user.errors.messages[:email].join).to include(I18n.t("errors.email.taken"))
      end
    end
  end

  context "initializing with just a user" do
    it "correctly assigns the user" do
      expect(subject.user).to eql(user)
    end

    it "has a nil email" do
      expect(subject.email).to be_nil
    end

    it { is_expected.to be_invalid }
  end

  context "initializing with a user and new email" do
    subject { described_class.new(user, email: new_email) }

    it "correctly assigns the user" do
      expect(subject.user).to eql(user)
    end

    it "correctly assigns the email" do
      expect(subject.email).to eql(new_email)
    end

    it { is_expected.to be_valid }
  end

  describe "#save" do
    let(:fake_user) { double(User, update!: true) }
    subject { described_class.new(fake_user, email: new_email) }

    it "updates the user using the provided name" do
      expect(subject.save).to be(true)
      expect(fake_user).to have_received(:update!).with(email: new_email).once
    end

    context "when the email isn't valid" do
      let(:email) { "not.an-email.com" }

      it "doesn't update the user" do
        user.save!
        expect(fake_user).not_to have_received(:update!)
      end
    end
  end
end

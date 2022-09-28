# frozen_string_literal: true

RSpec.describe Admin::Participants::NPQ::ChangeFullNameForm, type: :model do
  let(:new_full_name) { "Roger Test" }
  let(:user) { build(:user) }
  subject { described_class.new(user) }

  describe "validation" do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_length_of(:full_name).is_at_most(128) }
  end

  context "initializing with just a user" do
    it "correctly assigns the user" do
      expect(subject.user).to eql(user)
    end

    it "has a nil full name" do
      expect(subject.full_name).to be_nil
    end

    it { is_expected.to be_invalid }
  end

  context "initializing with a user and new full name" do
    subject { described_class.new(user, full_name: new_full_name) }

    it "correctly assigns the user" do
      expect(subject.user).to eql(user)
    end

    it "correctly assigns the full name" do
      expect(subject.full_name).to eql(new_full_name)
    end

    it { is_expected.to be_valid }
  end

  describe "#save" do
    let(:fake_user) { double(User, update!: true) }
    subject { described_class.new(fake_user, full_name: new_full_name) }

    it "updates the user using the provided name" do
      expect(subject.save).to be(true)
      expect(fake_user).to have_received(:update!).with(full_name: new_full_name).once
    end

    context "when the full name isn't valid" do
      let(:new_full_name) { "" }

      it "doesn't update the user" do
        user.save!
        expect(fake_user).not_to have_received(:update!)
      end
    end
  end
end

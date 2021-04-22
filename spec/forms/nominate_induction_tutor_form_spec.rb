# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominateInductionTutorForm, type: :model do
  let(:nomination_email) { create(:nomination_email) }
  let(:token) { nomination_email.token }
  let(:school) { nomination_email.school }
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  describe "validations" do
    it { is_expected.to validate_presence_of(:full_name).with_message("Enter a full name") }
    it { is_expected.to validate_presence_of(:email).with_message("Enter email") }
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

  describe "#save!" do
    let(:form) { NominateInductionTutorForm.new(token: token, full_name: name, email: email) }

    it "creates an induction coordinator with the correct details" do
      expect { form.save! }
        .to change { User.count }
              .by(1)
              .and change { InductionCoordinatorProfile.count }.by(1)

      created_user = User.find_by(email: email)
      expect(created_user).not_to be_nil
      expect(created_user.full_name).to eql name
      expect(created_user.induction_coordinator_profile.schools).to contain_exactly(school)
    end

    context "when a user with the specified email already exists" do
      before do
        create(:user, email: email)
      end

      it "raises UserExistsError" do
        expect { form.save! }.to raise_error(UserExistsError)
                                   .and(not_change { User.unscoped.count })
                                   .and(not_change { InductionCoordinatorProfile.unscoped.count })
      end
    end

    context "when a discarded user with the specified email exists" do
      before do
        user = create(:user, email: email)
        user.discard!
      end

      it "raises UserExistsError" do
        expect { form.save! }.to raise_error(UserExistsError)
                                   .and(not_change { User.unscoped.count })
                                   .and(not_change { InductionCoordinatorProfile.unscoped.count })
      end
    end
  end
end

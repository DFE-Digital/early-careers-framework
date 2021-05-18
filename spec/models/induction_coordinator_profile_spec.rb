# frozen_string_literal: true

require "rails_helper"

RSpec.describe InductionCoordinatorProfile, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:schools) }

  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe ".create_induction_coordinator" do
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:school) { create(:school) }
    let(:start_url) { "www.example.com" }
    let(:created_user) { User.find_by(email: email) }

    it "creates an induction coordinator" do
      expect {
        InductionCoordinatorProfile.create_induction_coordinator(name, email, school, start_url)
      }.to change { InductionCoordinatorProfile.count }.by(1)
    end

    it "creates a user with the correct details" do
      InductionCoordinatorProfile.create_induction_coordinator(name, email, school, start_url)

      expect(created_user.present?).to be(true)
      expect(created_user.full_name).to eql(name)
    end

    it "sends an email to the new user" do
      allow(SchoolMailer).to receive(:nomination_confirmation_email).and_call_original
      InductionCoordinatorProfile.create_induction_coordinator(name, email, school, start_url)

      expect(SchoolMailer).to have_received(:nomination_confirmation_email)
                                .with(user: created_user, school: school, start_url: start_url)
    end
  end
end

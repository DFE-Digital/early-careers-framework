# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateInductionTutor do
  let(:school) { create(:school) }
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  describe ".call" do
    it "creates a user with an induction coordinator profile" do
      expect {
        CreateInductionTutor.call(school: school, email: email, full_name: name)
      }.to change { InductionCoordinatorProfile.count }.by(1)
        .and change { User.count }.by(1)
    end

    it "emails the new induction tutor" do
      allow(SchoolMailer).to receive(:nomination_confirmation_email).and_call_original

      service = CreateInductionTutor.new(school: school, email: email, full_name: name)
      service.call

      expect(SchoolMailer).to have_received(:nomination_confirmation_email)
        .with(user: User.find_by(email: email), school: school, start_url: service.start_url)
    end

    context "when an induction coordinator exists" do
      let!(:existing_profile) { create(:induction_coordinator_profile, schools: [school]) }

      before do
        existing_profile
      end

      it "removes the existing induction coordinator" do
        expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

        CreateInductionTutor.call(school: school, email: email, full_name: name)

        user = User.find_by(email: email)
        expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
      end
    end
  end
end

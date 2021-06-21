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

    context "when an induction coordinator for the school exists" do
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

    context "when the details match an existing induction coordinator" do
      let!(:existing_induction_coordinator) { create(:user, :induction_coordinator) }

      it "adds the school to the existing coordinator" do
        allow(SchoolMailer).to receive(:nomination_confirmation_email).and_call_original

        service = CreateInductionTutor.new(
          school: school,
          email: existing_induction_coordinator.email,
          full_name: existing_induction_coordinator.full_name,
        )
        expect { service.call }.not_to change { User.count }
        expect(existing_induction_coordinator.schools.count).to eql 2
        expect(existing_induction_coordinator.schools).to include school

        expect(SchoolMailer).to have_received(:nomination_confirmation_email)
                                  .with(user: existing_induction_coordinator, school: school, start_url: service.start_url)
      end

      it "raises an exception if the name does not match the existing name" do
        allow(SchoolMailer).to receive(:nomination_confirmation_email).and_call_original

        service = CreateInductionTutor.new(
          school: school,
          email: existing_induction_coordinator.email,
          full_name: "Different Name",
        )

        expect { service.call }.to raise_exception(RuntimeError).and not_change { User.count }
        expect(existing_induction_coordinator.schools.count).to eql 1
        expect(existing_induction_coordinator.schools).not_to include school
        expect(SchoolMailer).not_to have_received(:nomination_confirmation_email)
      end
    end
  end
end

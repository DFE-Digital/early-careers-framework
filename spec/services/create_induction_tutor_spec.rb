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
      let!(:existing_user) { create(:user) }
      let!(:existing_profile) { create(:induction_coordinator_profile, schools: [school], user: existing_user) }

      it "removes the existing induction coordinator" do
        expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

        CreateInductionTutor.call(school: school, email: email, full_name: name)

        user = User.find_by(email: email)
        expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
        expect(InductionCoordinatorProfile.exists?(existing_profile.id)).to be false
        expect(User.exists?(existing_user.id)).to be false
      end

      context "when the induction coordinator has other schools" do
        let!(:other_school) { create(:school) }
        let!(:existing_profile) { create(:induction_coordinator_profile, schools: [school, other_school], user: existing_user) }

        it "removes the school from the existing induction coordinator" do
          expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

          CreateInductionTutor.call(school: school, email: email, full_name: name)

          user = User.find_by(email: email)
          expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
          expect(InductionCoordinatorProfile.exists?(existing_profile.id)).to be true
          expect(User.exists?(existing_user.id)).to be true
          expect(existing_user.schools).to contain_exactly(other_school)
        end

        context "when the induction coordinator is also a mentor" do
          let!(:mentor_profile) { create(:mentor_profile, user: existing_profile.user, school: school) }

          it "removes the school from the existing induction coordinator" do
            expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

            CreateInductionTutor.call(school: school, email: email, full_name: name)

            user = User.find_by(email: email)
            expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
            expect(InductionCoordinatorProfile.exists?(existing_profile.id)).to be true
            expect(User.exists?(existing_user.id)).to be true
            expect(ParticipantProfile::Mentor.exists?(mentor_profile.id)).to be true
            expect(existing_user.schools).to contain_exactly(other_school)
          end
        end
      end

      context "when the induction coordinator is also a mentor" do
        let!(:mentor_profile) { create(:mentor_profile, user: existing_profile.user, school: school) }

        it "retains the user but deletes the induction coordinator profile" do
          expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

          CreateInductionTutor.call(school: school, email: email, full_name: name)

          user = User.find_by(email: email)
          expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
          expect(InductionCoordinatorProfile.exists?(existing_profile.id)).to be false
          expect(User.exists?(existing_user.id)).to be true
          expect(ParticipantProfile::Mentor.exists?(mentor_profile.id)).to be true
        end
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

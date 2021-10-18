# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateInductionTutor do
  let(:school) { create(:school) }
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  describe ".call" do
    it "creates a user with an induction coordinator profile" do
      expect { CreateInductionTutor.call(school: school, email: email, full_name: name) }
        .to change { InductionCoordinatorProfile.count }.by(1)
        .and change { User.count }.by(1)
    end

    it "emails the new induction tutor" do
      service = CreateInductionTutor.new(school: school, email: email, full_name: name)
      service.call

      expect(SchoolMailer).to delay_email_delivery_of(:nomination_confirmation_email).with(
        sit_profile: User.find_by(email: email).induction_coordinator_profile,
        school: school,
        start_url: service.start_url,
        step_by_step_url: service.step_by_step_url,
      )
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
          expect(School.exists?(school.id)).to be true
        end

        context "when the induction coordinator is also a mentor" do
          let!(:mentor_profile) { create(:participant_profile, :mentor, user: existing_profile.user, school: school) }

          it "removes the school from the existing induction coordinator" do
            expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

            CreateInductionTutor.call(school: school, email: email, full_name: name)

            user = User.find_by(email: email)
            expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
            expect(InductionCoordinatorProfile.exists?(existing_profile.id)).to be true
            expect(User.exists?(existing_user.id)).to be true
            expect(ParticipantProfile::Mentor.exists?(mentor_profile.id)).to be true
            expect(existing_user.schools).to contain_exactly(other_school)
            expect(School.exists?(school.id)).to be true
          end
        end
      end

      context "when the induction coordinator is also a mentor" do
        let!(:mentor_profile) { create(:participant_profile, :mentor, user: existing_profile.user, school: school) }

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

      context "when the induction coordinator is also an npq" do
        let!(:npq_profile) { create(:participant_profile, :npq, user: existing_profile.user, school: school) }

        it "retains the user but deletes the induction coordinator profile" do
          expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

          CreateInductionTutor.call(school: school, email: email, full_name: name)

          user = User.find_by(email: email)
          expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
          expect(InductionCoordinatorProfile.exists?(existing_profile.id)).to be false
          expect(User.exists?(existing_user.id)).to be true
          expect(ParticipantProfile::NPQ.exists?(npq_profile.id)).to be true
        end
      end

      context "when the induction coordinator applied for npq" do
        let!(:npq_application) { create(:npq_application, user: existing_profile.user) }

        it "retains the user but deletes the induction coordinator profile" do
          expect(school.induction_coordinator_profiles.first).to eq(existing_profile)

          CreateInductionTutor.call(school: school, email: email, full_name: name)

          user = User.find_by(email: email)
          expect(school.reload.induction_coordinator_profiles.first).to eq(user.induction_coordinator_profile)
          expect(InductionCoordinatorProfile.exists?(existing_profile.id)).to be false
          expect(User.exists?(existing_user.id)).to be true
          expect(NPQApplication.exists?(npq_application.id)).to be true
        end
      end
    end

    context "when the details match an existing induction coordinator" do
      let!(:sit_profile) { create :induction_coordinator_profile }

      it "adds the school to the existing coordinator" do
        service = CreateInductionTutor.new(
          school: school,
          email: sit_profile.user.email,
          full_name: sit_profile.user.full_name,
        )

        expect { service.call }.not_to change { User.count }
        sit_profile.reload
        expect(sit_profile.schools.count).to eql 2
        expect(sit_profile.schools).to include school

        expect(SchoolMailer).to delay_email_delivery_of(:nomination_confirmation_email).with(
          sit_profile: sit_profile,
          school: school,
          start_url: service.start_url,
          step_by_step_url: service.step_by_step_url,
        )
      end

      it "raises an exception if the name does not match the existing name" do
        service = CreateInductionTutor.new(
          school: school,
          email: sit_profile.user.email,
          full_name: "Different Name",
        )

        expect { service.call }.to raise_exception(RuntimeError).and not_change { User.count }
        expect(sit_profile.schools.count).to eql 1
        expect(sit_profile.schools).not_to include school
        expect(SchoolMailer).not_to delay_email_delivery_of(:nomination_confirmation_email)
      end
    end
  end
end

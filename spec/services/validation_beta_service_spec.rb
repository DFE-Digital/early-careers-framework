# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidationBetaService do
  subject(:validation_beta_service) { described_class.new }

  describe "#remind_fip_induction_coordinators_to_add_ect_and_mentors" do
    let!(:school_cohort) { create(:school_cohort, induction_programme_choice: "full_induction_programme") }
    let(:school) { school_cohort.school }
    let!(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school]) }

    it "emails SITs that have chosen a FIP programme but have not added any ects or mentors" do
      validation_beta_service.remind_fip_induction_coordinators_to_add_ect_and_mentors
      expect(SchoolMailer).to delay_email_delivery_of(:remind_fip_induction_coordinators_to_add_ects_and_mentors_email)
                                .with(induction_coordinator: induction_coordinator,
                                      school_name: school.name,
                                      campaign: :remind_fip_sit_to_complete_steps)
    end

    it "does not email SIT whose school has added an ECT" do
      create(:participant_profile, :ect, school_cohort: school_cohort, school: school)

      validation_beta_service.remind_fip_induction_coordinators_to_add_ect_and_mentors
      expect(SchoolMailer).not_to delay_email_delivery_of(:remind_fip_induction_coordinators_to_add_ects_and_mentors_email)
                                    .with(induction_coordinator: induction_coordinator,
                                          school_name: school.name,
                                          campaign: :remind_fip_sit_to_complete_steps)
    end

    it "does not email SIT whose school has added an mentor" do
      create(:participant_profile, :mentor, school_cohort: school_cohort, school: school)

      validation_beta_service.remind_fip_induction_coordinators_to_add_ect_and_mentors
      expect(SchoolMailer).not_to delay_email_delivery_of(:remind_fip_induction_coordinators_to_add_ects_and_mentors_email)
                                    .with(induction_coordinator: induction_coordinator,
                                          school_name: school.name,
                                          campaign: :remind_fip_sit_to_complete_steps)
    end

    it "does not email SIT whose school has opted out of updates" do
      school_cohort.update!(opt_out_of_updates: true)

      validation_beta_service.remind_fip_induction_coordinators_to_add_ect_and_mentors
      expect(SchoolMailer).not_to delay_email_delivery_of(:remind_fip_induction_coordinators_to_add_ects_and_mentors_email)
                                .with(induction_coordinator: induction_coordinator,
                                      school_name: school.name,
                                      campaign: :remind_fip_sit_to_complete_steps)
    end

    it "does not email SIT whose school is on a core_induction_programme" do
      school_cohort.core_induction_programme!

      validation_beta_service.remind_fip_induction_coordinators_to_add_ect_and_mentors
      expect(SchoolMailer).not_to delay_email_delivery_of(:remind_fip_induction_coordinators_to_add_ects_and_mentors_email)
                                    .with(induction_coordinator: induction_coordinator,
                                          school_name: school.name,
                                          campaign: :remind_fip_sit_to_complete_steps)
    end
  end

  describe "#sit_with_unvalidated_participants_reminders" do
    it "emails sits with unvalidated participants who are on fip" do
      school_cohort = create(:school_cohort, :fip)

      expected_start_url = "http://www.example.com/participants/start-registration?utm_campaign=unvalidated-participants-reminder&utm_medium=email&utm_source=unvalidated-participants-reminder"
      expected_sign_in_url = "http://www.example.com/users/sign_in?utm_campaign=unvalidated-participants-reminder&utm_medium=email&utm_source=unvalidated-participants-reminder"

      create(:participant_profile, :mentor, school_cohort: school_cohort)
      create(:participant_profile, :ecf_participant_validation_data, :ect, school_cohort: school_cohort)
      sit = create(:induction_coordinator_profile, schools: [school_cohort.school])

      validation_beta_service.sit_with_unvalidated_participants_reminders

      expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: sit.user.email,
                                                       start_url: expected_start_url,
                                                       sign_in: expected_sign_in_url,
                                                     )).once
    end

    it "emails sits with unvalidated participants who are on cip" do
      school_cohort = create(:school_cohort, :cip)

      expected_start_url = "http://www.example.com/participants/start-registration?utm_campaign=unvalidated-participants-reminder&utm_medium=email&utm_source=unvalidated-participants-reminder"
      expected_sign_in_url = "http://www.example.com/users/sign_in?utm_campaign=unvalidated-participants-reminder&utm_medium=email&utm_source=unvalidated-participants-reminder"

      create(:participant_profile, :mentor, school_cohort: school_cohort)
      create(:participant_profile, :ecf_participant_validation_data, :ect, school_cohort: school_cohort)
      sit = create(:induction_coordinator_profile, schools: [school_cohort.school])

      validation_beta_service.sit_with_unvalidated_participants_reminders

      expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: sit.user.email,
                                                       start_url: expected_start_url,
                                                       sign_in: expected_sign_in_url,
                                                     )).once
    end

    it "doesn't email schools without a sit" do
      school_cohort = create(:school_cohort, :cip)
      create(:participant_profile, :mentor, school_cohort: school_cohort)
      create(:participant_profile, :ecf_participant_validation_data, :ect, school_cohort: school_cohort)

      validation_beta_service.sit_with_unvalidated_participants_reminders

      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: school_cohort.school.contact_email,
                                                     ))
    end

    it "doesn't email sits with all validated participants" do
      school_cohort = create(:school_cohort, :cip)
      create(:participant_profile, :ecf_participant_validation_data, :ect, school_cohort: school_cohort)
      sit = create(:induction_coordinator_profile, schools: [school_cohort.school])

      validation_beta_service.sit_with_unvalidated_participants_reminders

      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: sit.user.email,
                                                     ))
    end

    it "doesn't email sits on a different induction programme" do
      school_cohort = create(:school_cohort, :school_funded_fip)

      create(:participant_profile, :mentor, school_cohort: school_cohort)
      create(:participant_profile, :ecf_participant_validation_data, :ect, school_cohort: school_cohort)
      sit = create(:induction_coordinator_profile, schools: [school_cohort.school])

      validation_beta_service.sit_with_unvalidated_participants_reminders

      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: sit.user.email,
                                                     ))
    end
  end

  describe "#set_up_missing_chasers" do
    let!(:ect_profile) { create(:participant_profile, :ect) }
    let!(:mentor_profile) { create(:participant_profile, :mentor) }
    let!(:sit_mentor_profile) do
      mentor_profile = create(:participant_profile, :mentor)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      mentor_profile
    end
    let!(:validated_ect_profile) { create(:participant_profile, :ect, :ecf_participant_eligibility) }
    let!(:validated_mentor_profile) { create(:participant_profile, :mentor, :ecf_participant_eligibility) }
    let!(:validated_sit_mentor_profile) do
      mentor_profile = create(:participant_profile, :mentor, :ecf_participant_eligibility)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      mentor_profile
    end

    let!(:scheduled_ect_profile) do
      ect_profile = create(:participant_profile, :ect)
      ParticipantDetailsReminderJob.schedule(ect_profile)
      ect_profile
    end

    let!(:scheduled_mentor_profile) do
      mentor_profile = create(:participant_profile, :mentor)
      ParticipantDetailsReminderJob.schedule(mentor_profile)
      mentor_profile
    end

    let!(:scheduled_sit_mentor_profile) do
      mentor_profile = create(:participant_profile, :mentor)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      ParticipantDetailsReminderJob.schedule(mentor_profile)
      mentor_profile
    end

    it "schedules reminders for ECTs" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).to be_enqueued
                                                 .with(profile_id: ect_profile.id)
    end

    it "schedules reminders for mentors" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).to be_enqueued
                                                 .with(profile_id: mentor_profile.id)
    end

    it "schedules reminders for SIT mentors" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).to be_enqueued
                                                 .with(profile_id: sit_mentor_profile.id)
    end

    it "does not schedule reminders for ECTs who have validated" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).not_to be_enqueued
                                                 .with(profile_id: validated_ect_profile.id)
    end

    it "does not schedule reminders for mentors who have validated" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).not_to be_enqueued
                                                     .with(profile_id: validated_mentor_profile.id)
    end

    it "does not schedule reminders for SIT mentors who have validated" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).not_to be_enqueued
                                                     .with(profile_id: validated_sit_mentor_profile.id)
    end

    it "does not schedule reminders for ECTs with reminders scheduled" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).to be_enqueued
                                                     .with(profile_id: scheduled_ect_profile.id)
                                                     .once
    end

    it "does not schedule reminders for mentors with reminders scheduled" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).to be_enqueued
                                                 .with(profile_id: scheduled_mentor_profile.id)
                                                 .once
    end

    it "does not schedule reminders for SIT mentors with reminders scheduled" do
      validation_beta_service.set_up_missing_chasers
      expect(ParticipantDetailsReminderJob).to be_enqueued
                                                 .with(profile_id: scheduled_sit_mentor_profile.id)
                                                 .once
    end
  end

  describe "#send_sit_new_ambition_ects_and_mentors_added" do
    let(:school) { create(:school, name: "Trumpton High School") }
    let!(:school_cohort) { create(:school_cohort, school: school) }

    let(:ect_user_1) { create(:user, email: "ect1@example.com") }
    let(:teacher_profile_1) { create(:teacher_profile, school: school, user: ect_user_1) }
    let!(:ect_profile_1) { create(:participant_profile, :ect, school_cohort: school_cohort, teacher_profile: teacher_profile_1) }

    let(:ect_user_2) { create(:user, email: "ect2@example.com") }
    let(:teacher_profile_2) { create(:teacher_profile, school: school, user: ect_user_2) }
    let!(:ect_profile_2) { create(:participant_profile, :ect, school_cohort: school_cohort, teacher_profile: teacher_profile_2) }

    let(:sit_user) { create(:user, email: "sit@example.com") }
    let!(:sit_profile) { create(:induction_coordinator_profile, user: sit_user, schools: [school]) }
    let(:csv_file) { file_fixture "ambition_users.csv" }

    it "sends the new ects and mentors email to the sit for the participant once only" do
      expect(school.induction_coordinator_profiles).to include sit_profile
      validation_beta_service.send_sit_new_ambition_ects_and_mentors_added(path_to_csv: csv_file)
      expect(SchoolMailer).to delay_email_delivery_of(:sit_new_ambition_ects_and_mentors_added_email)
                                .with(induction_coordinator: sit_profile,
                                      school_name: school.name,
                                      sign_in_url: "http://www.example.com/users/sign_in").once
    end
  end

  describe "#send_ineligible_previous_induction_batch" do
    let(:school_cohort) { create(:school_cohort, :fip) }
    let(:participant_profiles) { create_list(:participant_profile, 10, :ect, school_cohort: school_cohort) }
    let!(:eligibilities) do
      participant_profiles.each do |profile|
        create(:ecf_participant_eligibility, :ineligible, previous_induction: true, reason: :previous_induction, participant_profile: profile)
      end
    end

    it "sends the correct batch size" do
      # When called with a batch size of 5
      subject.send_ineligible_previous_induction_batch(batch_size: 5)

      # Then 5 emails should be sent
      expect(IneligibleParticipantMailer).to delay_email_delivery_of(:ect_previous_induction_email).exactly(5).times
    end

    context "when emails have been sent" do
      before do
        participant_profiles.each do |profile|
          create(:email, associated_with: [profile], tags: %w[ineligible_participant])
        end
      end

      it "does not email participants already emailed" do
        # When called
        subject.send_ineligible_previous_induction_batch(batch_size: 5)

        # Then no emails should be sent
        expect(IneligibleParticipantMailer).not_to delay_email_delivery_of(:ect_previous_induction_email)
      end
    end

    context "when participants are for CIP" do
      let(:school_cohort) { create(:school_cohort, :cip) }

      it "does not email CIP participants" do
        # When called
        subject.send_ineligible_previous_induction_batch(batch_size: 5)

        # Then no emails should be sent
        expect(IneligibleParticipantMailer).not_to delay_email_delivery_of(:ect_previous_induction_email)
      end
    end

    context "when participants are eligible" do
      let!(:eligibilities) do
        participant_profiles.each do |profile|
          create(:ecf_participant_eligibility, :eligible, previous_induction: true, reason: :previous_induction, participant_profile: profile)
        end
      end

      it "does not email eligible participants" do
        # When called
        subject.send_ineligible_previous_induction_batch(batch_size: 5)

        # Then no emails should be sent
        expect(IneligibleParticipantMailer).not_to delay_email_delivery_of(:ect_previous_induction_email)
      end
    end

    context "when participants are withdrawn" do
      let(:participant_profiles) { create_list(:participant_profile, 10, :ect, :withdrawn_record, school_cohort: school_cohort) }

      it "does not email inactive participants" do
        # When called
        subject.send_ineligible_previous_induction_batch(batch_size: 5)

        # Then no emails should be sent
        expect(IneligibleParticipantMailer).not_to delay_email_delivery_of(:ect_previous_induction_email)
      end
    end

    context "when the participants are ineligible for a different reason" do
      let!(:eligibilities) do
        participant_profiles.each do |profile|
          create(:ecf_participant_eligibility, :ineligible, previous_participation: true, reason: :previous_participation, participant_profile: profile)
        end
      end

      it "does not email participants who are only ineligible for a different reason" do
        # When called
        subject.send_ineligible_previous_induction_batch(batch_size: 5)

        # Then no emails should be sent
        expect(IneligibleParticipantMailer).not_to delay_email_delivery_of(:ect_previous_induction_email)
      end
    end
  end
end

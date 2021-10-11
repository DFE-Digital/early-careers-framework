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
end

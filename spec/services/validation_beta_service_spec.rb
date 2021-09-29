# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidationBetaService do
  subject(:validation_beta_service) { described_class.new }
  let(:fip_school_1) { create(:school_cohort, :fip).school }
  let(:fip_school_2) { create(:school_cohort, :fip).school }
  let(:cip_school) { create(:school_cohort, :cip).school }
  let!(:mentor_1) { create(:participant_profile, :mentor, school: fip_school_1) }
  let!(:mentor_2) { create(:participant_profile, :mentor, school: fip_school_2) }
  let!(:mentor_3) { create(:participant_profile, :mentor, school: cip_school) }
  let!(:ect_1) { create(:participant_profile, :ect, school: fip_school_1) }
  let!(:ect_2) { create(:participant_profile, :ect, school: fip_school_2) }
  let!(:ect_3) { create(:participant_profile, :ect, school: cip_school) }
  let!(:induction_coordinator) { create(:user, :induction_coordinator, school_ids: [fip_school_1.id]) }
  let!(:induction_coordinator_2) { create(:user, :induction_coordinator, school_ids: [fip_school_2.id]) }
  let!(:induction_coordinator_3) { create(:user, :induction_coordinator, school_ids: [cip_school.id]) }
  let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=participant-validation-beta&utm_medium=email&utm_source=participant-validation-beta" }
  let(:research_url) { "http://www.example.com/pages/user-research?utm_campaign=participant-validation-research&utm_medium=email&utm_source=participant-validation-research" }
  let(:mentor_research_url) { "http://www.example.com/pages/user-research?mentor=true&utm_campaign=participant-validation-research&utm_medium=email&utm_source=participant-validation-research" }
  let(:coordinator_mentor_research_url) { "http://www.example.com/pages/sit-user-research?utm_campaign=participant-validation-research&utm_medium=email&utm_source=participant-validation-research" }
  let(:induction_coordinator_start_url) { "http://www.example.com/?utm_campaign=participant-validation-sit-notification&utm_medium=email&utm_source=cpdservice" }
  let(:schools) { [fip_school_1, fip_school_2, cip_school] }
  let(:urns) { schools.map(&:urn) }

  describe "#tell_ects_to_add_validation_information" do
    let!(:chosen_programme_school) { create(:school_cohort, :cip).school }

    let!(:chosen_programme_ect) do
      create(:participant_profile, :ect, school: chosen_programme_school)
    end
    let!(:chosen_programme_ect_already_received_before_automation_launch) do
      create(:participant_profile, :ect, school: chosen_programme_school, request_for_details_sent_at: Time.zone.parse("2021-09-16"))
    end
    let!(:chosen_programme_ect_already_received_after_automation_launch) do
      create(:participant_profile, :ect, school: chosen_programme_school, request_for_details_sent_at: ValidationBetaService::AUTOMATION_LAUNCH_TIME + 1.minute)
    end
    let!(:chosen_programme_mentor) do
      create(:participant_profile, :mentor, school: chosen_programme_school)
    end

    let!(:provided_validation_details_ect) do
      create(:participant_profile, :ect, :ecf_participant_validation_data, school: chosen_programme_school)
    end
    let!(:provided_eligibility_details_ect) do
      create(:participant_profile, :ect, :ecf_participant_eligibility, school: chosen_programme_school)
    end

    let(:cohort_without_programme) { create :school_cohort, induction_programme_choice: "not_yet_known" }
    let!(:not_chosen_programme_ect) { create(:participant_profile, :ect, school_cohort: cohort_without_programme) }

    let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=ect-validation-info-2709&utm_medium=email&utm_source=ect-validation-info-2709" }

    it "emails ECTs that have chosen programme but have not provided details and haven't already received the email" do
      validation_beta_service.tell_ects_to_add_validation_information
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "emails ECTs that have already received the email before validation automation (and not provided details)" do
      validation_beta_service.tell_ects_to_add_validation_information
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect_already_received_before_automation_launch.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "only emails the number of times specified by the limit" do
      validation_beta_service.tell_ects_to_add_validation_information(limit: 1)
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:ects_to_add_validation_information_email).once
    end

    it "doesn't email ECTs that have already received the email after validation automation (and not provided details)" do
      validation_beta_service.tell_ects_to_add_validation_information
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect_already_received_after_automation_launch.user.email,
                                                     )).once
    end

    it "doesn't email mentors that have chosen programme but have not provided details" do
      validation_beta_service.tell_ects_to_add_validation_information
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor.user.email,
                                                     )).once
    end

    it "doesn't email ECTs that have not chosen programme" do
      validation_beta_service.tell_ects_to_add_validation_information
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_ect.user.email,
                                                     ))
    end

    it "doesn't email ECTs that have have provided validation details" do
      validation_beta_service.tell_ects_to_add_validation_information
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_validation_details_ect.user.email,
                                                     ))
    end

    it "doesn't email ECTs that have have provided eligibility details" do
      validation_beta_service.tell_ects_to_add_validation_information
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_eligibility_details_ect.user.email,
                                                     ))
    end
  end

  describe "#tell_mentors_to_add_validation_information" do
    let(:chosen_programme_cohort) { create(:school_cohort, :fip) }
    let!(:chosen_programme_school) { chosen_programme_cohort.school }

    let!(:chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort)
    end
    let!(:chosen_programme_mentor_already_received_before_automation_launch) do
      create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort, request_for_details_sent_at: Time.zone.parse("2021-09-16"))
    end
    let!(:chosen_programme_mentor_already_received_after_automation_launch) do
      create(:participant_profile, :mentor, school: chosen_programme_school, request_for_details_sent_at: Time.zone.now)
    end

    let!(:chosen_programme_ect) do
      create(:participant_profile, :ect, school_cohort: chosen_programme_cohort)
    end

    let!(:cip_chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: create(:school_cohort, :cip))
    end
    let!(:cip_chosen_programme_school) do
      cip_chosen_programme_mentor.school_cohort.school
    end

    let!(:school_funded_fip_chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: create(:school_cohort, :school_funded_fip))
    end

    let!(:provided_validation_details_mentor) do
      create(:participant_profile, :mentor, :ecf_participant_validation_data, school_cohort: chosen_programme_cohort)
    end
    let!(:provided_eligibility_details_mentor) do
      create(:participant_profile, :mentor, :ecf_participant_eligibility, school_cohort: chosen_programme_cohort)
    end

    let(:cohort_without_programme) { create :school_cohort, induction_programme_choice: "not_yet_known" }
    let!(:not_chosen_programme_mentor) { create(:participant_profile, :ect, school_cohort: cohort_without_programme) }

    let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=mentor-validation-info-2709&utm_medium=email&utm_source=mentor-validation-info-2709" }

    it "emails FIP mentors that have chosen programme but have not provided details" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "emails CIP mentors that have chosen programme but have not provided details" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: cip_chosen_programme_mentor.user.email,
                                                       school_name: cip_chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "email mentors that have already received an invitation email before automation launch" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor_already_received_before_automation_launch.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "doesn't email mentors that have already received an invitation email after automation launch" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor_already_received_after_automation_launch.user.email,
                                                     )).once
    end

    it "doesn't email ECTs that have chosen programme but have not provided details" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect.user.email,
                                                     )).once
    end

    it "doesn't email non CIP/FIP mentors that have chosen programme but have not provided details" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: school_funded_fip_chosen_programme_mentor.user.email,
                                                     )).once
    end

    it "doesn't email mentors that have not chosen programme" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_mentor.user.email,
                                                     ))
    end

    it "doesn't email mentors that have provided validation details" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_validation_details_mentor.user.email,
                                                     ))
    end

    it "doesn't email mentors that have provided eligibility details" do
      validation_beta_service.tell_mentors_to_add_validation_information
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_eligibility_details_mentor.user.email,
                                                     ))
    end

    it "only emails the number of times specified by the limit" do
      validation_beta_service.tell_mentors_to_add_validation_information(limit: 1)
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:mentors_to_add_validation_information_email).once
    end
  end

  describe "#tell_induction_coordinators_who_are_mentors_to_add_validation_information" do
    let(:chosen_programme_cohort) { create(:school_cohort, :cip) }
    let!(:chosen_programme_school) { chosen_programme_cohort.school }

    let!(:chosen_programme_mentor_and_ic) do
      mentor_profile = create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      mentor_profile
    end
    let!(:chosen_programme_mentor_and_ic_already_received) do
      mentor_profile = create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort, request_for_details_sent_at: Time.zone.now)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      mentor_profile
    end
    let!(:chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort)
    end
    let!(:chosen_programme_ic) do
      create(:induction_coordinator_profile, schools: [chosen_programme_school])
    end

    let!(:provided_validation_details_mentor_and_ic) do
      mentor_profile = create(:participant_profile, :mentor, :ecf_participant_validation_data, school_cohort: chosen_programme_cohort)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      mentor_profile
    end
    let!(:provided_eligibility_details_mentor_and_ic) do
      mentor_profile = create(:participant_profile, :mentor, :ecf_participant_eligibility, school_cohort: chosen_programme_cohort)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      mentor_profile
    end

    let(:cohort_without_programme) { create :school_cohort, induction_programme_choice: "not_yet_known" }
    let!(:not_chosen_programme_mentor_and_ic) do
      mentor_profile = create(:participant_profile, :ect, school_cohort: cohort_without_programme)
      create(:induction_coordinator_profile, user: mentor_profile.user)
      mentor_profile
    end

    let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=sit-mentor-validation-info-2709&utm_medium=email&utm_source=sit-mentor-validation-info-2709" }

    before do
      validation_beta_service.tell_induction_coordinators_who_are_mentors_to_add_validation_information
    end

    it "emails mentors who are SITs that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinators_who_are_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor_and_ic.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "doesn't mentors who are SITS that have already received an invitation email" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:induction_coordinators_who_are_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor_and_ic_already_received.user.email,
                                                     )).once
    end

    it "doesn't email mentors that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:induction_coordinators_who_are_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor.user.email,
                                                     )).once
    end

    it "doesn't email SITs that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:induction_coordinators_who_are_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ic.user.email,
                                                     )).once
    end

    it "doesn't email mentors who are SITs that have not chosen programme" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_who_are_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_mentor_and_ic.user.email,
                                                     ))
    end

    it "doesn't email mentors who are SITs that have provided validation details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_who_are_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_validation_details_mentor_and_ic.user.email,
                                                     ))
    end

    it "doesn't email mentors who are SITs that have provided eligibility details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_who_are_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_eligibility_details_mentor_and_ic.user.email,
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

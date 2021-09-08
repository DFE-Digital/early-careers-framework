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

  describe "#tell_induction_coordinators_we_asked_ects_and_mentors_for_information" do
    let!(:chosen_programme_and_not_in_beta_school) { create(:school_cohort, :fip).school }
    let!(:chosen_programme_and_not_in_beta_school2) { create(:school_cohort, :fip).school }
    let!(:chosen_programme_and_not_in_beta_ic) do
      create(:user, :induction_coordinator, school_ids: [chosen_programme_and_not_in_beta_school.id, chosen_programme_and_not_in_beta_school2.id])
    end

    let!(:chosen_programme_and_not_in_beta_opted_out_school) do
      create(:school_cohort, induction_programme_choice: :no_early_career_teachers, opt_out_of_updates: true).school
    end
    let!(:chosen_programme_and_not_in_beta_opted_out_ic) do
      create(:user, :induction_coordinator, school_ids: [chosen_programme_and_not_in_beta_opted_out_school.id])
    end

    let!(:not_chosen_programme_and_not_in_beta_school) { create(:school) }
    let!(:not_chosen_programme_and_not_in_beta_ic) do
      create(:user, :induction_coordinator, school_ids: [not_chosen_programme_and_not_in_beta_school.id])
    end

    let!(:chosen_programme_and_in_beta_school) { create(:school_cohort, :fip).school }
    let!(:chosen_programme_and_in_beta_ic) do
      create(:user, :induction_coordinator, school_ids: [chosen_programme_and_in_beta_school.id])
    end

    let(:sign_in_url) { "http://www.example.com/users/sign_in?utm_campaign=asked-ects-and-mentors-for-information&utm_medium=email&utm_source=asked-ects-and-mentors-for-information" }

    before do
      FeatureFlag.activate(:participant_validation, for: chosen_programme_and_in_beta_school)

      validation_beta_service.tell_induction_coordinators_we_asked_ects_and_mentors_for_information
    end

    it "emails SITs that have chosen programme but not in validation beta, once per SIT even with multiple matching schools" do
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_and_not_in_beta_ic.email,
                                                       sign_in: sign_in_url,
                                                     ))
    end

    it "doesn't emails schools that have not chosen programme and were not in validation beta" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_and_not_in_beta_ic.email,
                                                     ))
    end

    it "doesn't email schools that have chosen a programme and were in validation beta" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_and_in_beta_ic.email,
                                                     ))
    end

    it "doesn't email schools that have chosen programme and not in validation beta if they have opted out of updates" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinators_we_asked_ects_and_mentors_for_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_and_not_in_beta_opted_out_ic.email,
                                                     ))
    end
  end

  describe "#tell_ects_to_add_validation_information" do
    let!(:chosen_programme_school) { create(:school_cohort, :cip).school }

    let!(:chosen_programme_ect) do
      create(:participant_profile, :ect, school: chosen_programme_school)
    end
    let!(:chosen_programme_ect_already_received) do
      create(:participant_profile, :ect, school: chosen_programme_school, request_for_details_sent_at: Time.zone.now)
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

    let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=ects-to-add-validation-information&utm_medium=email&utm_source=ects-to-add-validation-information" }

    before do
      validation_beta_service.tell_ects_to_add_validation_information
    end

    it "emails ECTs that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "doesn't email ECTs that have already received an invitation email" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect_already_received.user.email,
                                                     )).once
    end

    it "doesn't email mentors that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor.user.email,
                                                     )).once
    end

    it "doesn't email ECTs that have not chosen programme" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_ect.user.email,
                                                     ))
    end

    it "doesn't email ECTs that have have provided validation details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_validation_details_ect.user.email,
                                                     ))
    end

    it "doesn't email ECTs that have have provided eligibility details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:ects_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_eligibility_details_ect.user.email,
                                                     ))
    end
  end

  describe "#tell_fip_mentors_to_add_validation_information" do
    let(:chosen_programme_cohort) { create(:school_cohort, :fip) }
    let!(:chosen_programme_school) { chosen_programme_cohort.school }

    let!(:chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort)
    end
    let!(:chosen_programme_mentor_already_received) do
      create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort, request_for_details_sent_at: Time.zone.now)
    end
    let!(:chosen_programme_ect) do
      create(:participant_profile, :ect, school_cohort: chosen_programme_cohort)
    end

    let!(:cip_chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: create(:school_cohort, :cip))
    end

    let!(:provided_validation_details_mentor) do
      create(:participant_profile, :mentor, :ecf_participant_validation_data, school_cohort: chosen_programme_cohort)
    end
    let!(:provided_eligibility_details_mentor) do
      create(:participant_profile, :mentor, :ecf_participant_eligibility, school_cohort: chosen_programme_cohort)
    end

    let(:cohort_without_programme) { create :school_cohort, induction_programme_choice: "not_yet_known" }
    let!(:not_chosen_programme_mentor) { create(:participant_profile, :ect, school_cohort: cohort_without_programme) }

    let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=fip-mentors-to-add-validation-information&utm_medium=email&utm_source=fip-mentors-to-add-validation-information" }

    before do
      validation_beta_service.tell_fip_mentors_to_add_validation_information
    end

    it "emails FIP mentors that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:fip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "doesn't email FIP mentors that have already received an invitation email" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:fip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor_already_received.user.email,
                                                     )).once
    end

    it "doesn't email ECTs that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:fip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect.user.email,
                                                     )).once
    end

    it "doesn't email CIP mentors that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:fip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: cip_chosen_programme_mentor.user.email,
                                                     )).once
    end

    it "doesn't email mentors that have not chosen programme" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:fip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_mentor.user.email,
                                                     ))
    end

    it "doesn't email mentors that have provided validation details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:fip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_validation_details_mentor.user.email,
                                                     ))
    end

    it "doesn't email mentors that have provided eligibility details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:fip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_eligibility_details_mentor.user.email,
                                                     ))
    end
  end

  describe "#tell_cip_mentors_to_add_validation_information" do
    let(:chosen_programme_cohort) { create(:school_cohort, :cip) }
    let!(:chosen_programme_school) { chosen_programme_cohort.school }

    let!(:chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort)
    end
    let!(:chosen_programme_mentor_already_received) do
      create(:participant_profile, :mentor, school_cohort: chosen_programme_cohort, request_for_details_sent_at: Time.zone.now)
    end
    let!(:chosen_programme_ect) do
      create(:participant_profile, :ect, school_cohort: chosen_programme_cohort)
    end

    let!(:fip_chosen_programme_mentor) do
      create(:participant_profile, :mentor, school_cohort: create(:school_cohort, :fip))
    end

    let!(:provided_validation_details_mentor) do
      create(:participant_profile, :mentor, :ecf_participant_validation_data, school_cohort: chosen_programme_cohort)
    end
    let!(:provided_eligibility_details_mentor) do
      create(:participant_profile, :mentor, :ecf_participant_eligibility, school_cohort: chosen_programme_cohort)
    end

    let(:cohort_without_programme) { create :school_cohort, induction_programme_choice: "not_yet_known" }
    let!(:not_chosen_programme_mentor) { create(:participant_profile, :ect, school_cohort: cohort_without_programme) }

    let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=cip-mentors-to-add-validation-information&utm_medium=email&utm_source=cip-mentors-to-add-validation-information" }

    before do
      validation_beta_service.tell_cip_mentors_to_add_validation_information
    end

    it "emails CIP mentors that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:cip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor.user.email,
                                                       school_name: chosen_programme_school.name,
                                                       start_url: start_url,
                                                     )).once
    end

    it "doesn't email CIP mentors that have already received an invitation email" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:cip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_mentor_already_received.user.email,
                                                     )).once
    end

    it "doesn't email ECTs that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:cip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_ect.user.email,
                                                     )).once
    end

    it "doesn't email FIP mentors that have chosen programme but have not provided details" do
      expect(ParticipantValidationMailer).not_to delay_email_delivery_of(:cip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: fip_chosen_programme_mentor.user.email,
                                                     )).once
    end

    it "doesn't email mentors that have not chosen programme" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:cip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_mentor.user.email,
                                                     ))
    end

    it "doesn't email mentors that have provided validation details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:cip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_validation_details_mentor.user.email,
                                                     ))
    end

    it "doesn't email mentors that have provided eligibility details" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:cip_mentors_to_add_validation_information_email)
                                               .with(hash_including(
                                                       recipient: provided_eligibility_details_mentor.user.email,
                                                     ))
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

    let(:start_url) { "http://www.example.com/participants/start-registration?utm_campaign=induction-coordinators-who-are-mentors-to-add-validation-information&utm_medium=email&utm_source=induction-coordinators-who-are-mentors-to-add-validation-information" }

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
end

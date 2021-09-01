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

  describe "#invite_schools" do
    it "activates the participant validation feature flag for schools" do
      validation_beta_service.invite_schools(array_of_urns: urns, participant_research: false, coordinator_research: false)

      [fip_school_1, fip_school_2, cip_school].each do |school|
        expect(FeatureFlag.active?(:participant_validation, for: school)).to be true
      end
    end

    context "when not carrying out participant research" do
      before do
        validation_beta_service.invite_schools(array_of_urns: urns, participant_research: false, coordinator_research: false)
      end

      it "emails the induction coordinator" do
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinator_email)
                                                 .with(hash_including(
                                                         recipient: induction_coordinator.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: induction_coordinator_start_url,
                                                       ))
      end

      it "emails early career teachers" do
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:ect_email)
                                                 .with(hash_including(
                                                         recipient: ect_1.user.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: start_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:ect_email)
                                                 .with(hash_including(
                                                         recipient: ect_2.user.email,
                                                         school_name: fip_school_2.name,
                                                         start_url: start_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:ect_email)
                                                 .with(hash_including(
                                                         recipient: ect_3.user.email,
                                                         school_name: cip_school.name,
                                                         start_url: start_url,
                                                       ))
      end

      it "emails mentors" do
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:fip_mentor_email)
                                                 .with(hash_including(
                                                         recipient: mentor_1.user.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: start_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:fip_mentor_email)
                                                 .with(hash_including(
                                                         recipient: mentor_2.user.email,
                                                         school_name: fip_school_2.name,
                                                         start_url: start_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:cip_mentor_email)
                                                 .with(hash_including(
                                                         recipient: mentor_3.user.email,
                                                         school_name: cip_school.name,
                                                         start_url: start_url,
                                                       ))
      end
    end

    context "when carrying out participant research" do
      before do
        validation_beta_service.invite_schools(array_of_urns: urns, participant_research: true, coordinator_research: false)
      end

      it "notifies the induction coordinator of UR" do
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinator_ur_email)
                                                 .with(hash_including(
                                                         recipient: induction_coordinator.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: induction_coordinator_start_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinator_ur_email)
                                                 .with(hash_including(
                                                         recipient: induction_coordinator_2.email,
                                                         school_name: fip_school_2.name,
                                                         start_url: induction_coordinator_start_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinator_ur_email)
                                                 .with(hash_including(
                                                         recipient: induction_coordinator_3.email,
                                                         school_name: cip_school.name,
                                                         start_url: induction_coordinator_start_url,
                                                       ))
      end

      it "emails early career teachers for UR" do
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:ect_ur_email)
                                                 .with(hash_including(
                                                         recipient: ect_1.user.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: start_url,
                                                         user_research_url: research_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:ect_ur_email)
                                                 .with(hash_including(
                                                         recipient: ect_2.user.email,
                                                         school_name: fip_school_2.name,
                                                         start_url: start_url,
                                                         user_research_url: research_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:ect_email)
                                                 .with(hash_including(
                                                         recipient: ect_3.user.email,
                                                         school_name: cip_school.name,
                                                         start_url: start_url,
                                                       ))
      end

      it "emails mentors for UR" do
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:fip_mentor_ur_email)
                                                 .with(hash_including(
                                                         recipient: mentor_1.user.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: start_url,
                                                         user_research_url: mentor_research_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:fip_mentor_ur_email)
                                                 .with(hash_including(
                                                         recipient: mentor_2.user.email,
                                                         school_name: fip_school_2.name,
                                                         start_url: start_url,
                                                         user_research_url: mentor_research_url,
                                                       ))
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:cip_mentor_email)
                                                 .with(hash_including(
                                                         recipient: mentor_3.user.email,
                                                         school_name: cip_school.name,
                                                         start_url: start_url,
                                                       ))
      end
    end

    context "when the coordinator is also a mentor" do
      before do
        create(:participant_profile, :mentor, user: induction_coordinator, school_cohort: fip_school_1.school_cohorts.first)
      end

      it "emails the induction coordinator a notification" do
        validation_beta_service.invite_schools(array_of_urns: urns, participant_research: false, coordinator_research: false)
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinator_email)
                                                 .with(hash_including(
                                                         recipient: induction_coordinator.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: induction_coordinator_start_url,
                                                       ))
      end

      it "emails the induction coordinator to enter their details" do
        validation_beta_service.invite_schools(array_of_urns: urns, participant_research: false, coordinator_research: false)
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:coordinator_and_mentor_email)
                                                 .with(hash_including(
                                                         recipient: induction_coordinator.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: start_url,
                                                       ))
      end

      it "emails the induction coordinator to enter their details" do
        validation_beta_service.invite_schools(array_of_urns: urns, participant_research: false, coordinator_research: true)
        expect(ParticipantValidationMailer).to delay_email_delivery_of(:coordinator_and_mentor_ur_email)
                                                 .with(hash_including(
                                                         recipient: induction_coordinator.email,
                                                         school_name: fip_school_1.name,
                                                         start_url: start_url,
                                                         user_research_url: coordinator_mentor_research_url,
                                                       ))
      end
    end

    it "sends the correct emails to mentors in the engage beta" do
      user = create(:user, id: "36049a75-5c7c-4a64-849d-972bac8187ea")
      create(:participant_profile, :mentor, user: user, school_cohort: cip_school.school_cohorts.first)

      validation_beta_service.invite_schools(array_of_urns: urns, participant_research: false, coordinator_research: false)

      expect(ParticipantValidationMailer).to delay_email_delivery_of(:engage_beta_mentor_email)
                                               .with(hash_including(
                                                       recipient: user.email,
                                                       school_name: cip_school.name,
                                                       start_url: start_url,
                                                     ))
    end
  end

  describe "#notify_induction_coordinators_about_validation" do
    let!(:chosen_programme_and_not_in_beta_school) { create(:school_cohort, :fip).school }
    let!(:chosen_programme_and_not_in_beta_ic) do
      create(:user, :induction_coordinator, school_ids: [chosen_programme_and_not_in_beta_school.id])
    end

    let!(:not_chosen_programme_and_not_in_beta_school) { create(:school) }
    let!(:not_chosen_programme_and_not_in_beta_ic) do
      create(:user, :induction_coordinator, school_ids: [not_chosen_programme_and_not_in_beta_school.id])
    end

    let!(:chosen_programme_and_in_beta_school) { create(:school_cohort, :fip).school }
    let!(:chosen_programme_and_in_beta_ic) do
      create(:user, :induction_coordinator, school_ids: [chosen_programme_and_in_beta_school.id])
    end

    before do
      FeatureFlag.activate(:participant_validation, for: chosen_programme_and_in_beta_school)

      validation_beta_service.notify_induction_coordinators_about_validation
    end

    it "emails schools that have added chosen programme but not in validation beta" do
      expect(ParticipantValidationMailer).to delay_email_delivery_of(:induction_coordinator_validation_notification_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_and_not_in_beta_ic.email,
                                                       start_url: induction_coordinator_start_url,
                                                     ))
    end

    it "doesn't emails schools that have not chosen programme and were not in validaiton beta" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinator_validation_notification_email)
                                               .with(hash_including(
                                                       recipient: not_chosen_programme_and_not_in_beta_ic.email,
                                                       start_url: induction_coordinator_start_url,
                                                     ))
    end

    it "doesn't email schools that have chosen a programme and were in validation beta" do
      expect(ParticipantValidationMailer).to_not delay_email_delivery_of(:induction_coordinator_validation_notification_email)
                                               .with(hash_including(
                                                       recipient: chosen_programme_and_in_beta_ic.email,
                                                       start_url: induction_coordinator_start_url,
                                                     ))
    end
  end
end

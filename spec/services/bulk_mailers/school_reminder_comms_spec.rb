# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkMailers::SchoolReminderComms, type: :mailer do
  let(:cohort) { create(:seed_cohort) }
  let(:query_cohort) { cohort }
  let(:dry_run) { false }
  let(:email_schedule) { nil }

  let(:school_cohort) { create(:seed_school_cohort, :fip, :with_school, cohort:) }
  let(:school) { school_cohort.school }
  let(:lead_provider) { create(:seed_lead_provider, :valid) }
  let(:delivery_partner) { create(:seed_delivery_partner, :valid) }
  let(:partnership) { create(:seed_partnership, lead_provider:, delivery_partner:, cohort:, school:) }
  let(:induction_programme) { create(:seed_induction_programme, :fip, partnership:, school_cohort:) }
  let!(:sit_profile) { create(:seed_induction_coordinator_profiles_school, :valid, school:).induction_coordinator_profile }

  subject(:service) { described_class.new(cohort: query_cohort, dry_run:) }

  before do
    school.update!(school_type_code: 1)
  end

  describe "#contact_sits_that_need_to_chase_their_ab_to_register_ects" do
    let(:participant_profile) { create(:seed_ect_participant_profile, :valid, school_cohort:) }
    let(:ect_name) { participant_profile.user.full_name }

    let(:ect_appropriate_body) { nil }
    let(:school_appropriate_body) { nil }
    let!(:eligibility) { create(:seed_ecf_participant_eligibility, :no_induction, participant_profile:) }
    let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:, induction_programme:, appropriate_body: ect_appropriate_body) }

    before do
      school_cohort.update!(appropriate_body: school_appropriate_body)
    end

    context "when a school has ECTs without an induction start date" do
      context "when there is an AB appointed" do
        let(:school_appropriate_body) { create(:seed_appropriate_body, :valid) }

        it "mails the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_chase_their_ab_to_register_ects
          }.to have_enqueued_mail(SchoolMailer, :remind_sit_that_ab_has_not_registered_ect)
            .with(params: { school:, induction_coordinator: sit_profile, ect_name:, appropriate_body_name: school_appropriate_body.name, lead_provider_name: lead_provider.name, delivery_partner_name: delivery_partner.name }, args: [])
        end

        it "returns the count of emails sent" do
          expect(service.contact_sits_that_need_to_chase_their_ab_to_register_ects).to eq 1
        end

        context "when the AB is set at the participant level" do
          let(:ect_appropriate_body) { create(:seed_appropriate_body, :valid) }

          it "mails the induction coordinator using the participant-level AB" do
            expect {
              service.contact_sits_that_need_to_chase_their_ab_to_register_ects
            }.to have_enqueued_mail(SchoolMailer, :remind_sit_that_ab_has_not_registered_ect)
              .with(params: { school:, induction_coordinator: sit_profile, ect_name:, appropriate_body_name: ect_appropriate_body.name, lead_provider_name: lead_provider.name, delivery_partner_name: delivery_partner.name }, args: [])
          end

          it "returns the count of emails sent" do
            expect(service.contact_sits_that_need_to_chase_their_ab_to_register_ects).to eq 1
          end
        end

        context "when the dry_run flag is set" do
          let(:dry_run) { true }

          it "does not mail the induction coordinator" do
            expect {
              service.contact_sits_that_need_to_chase_their_ab_to_register_ects
            }.not_to have_enqueued_mail
          end

          it "returns the count of emails that would have been sent" do
            expect(service.contact_sits_that_need_to_chase_their_ab_to_register_ects).to eq 1
          end
        end
      end

      context "when no AB has been appointed" do
        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_chase_their_ab_to_register_ects
          }.not_to have_enqueued_mail(SchoolMailer, :remind_sit_that_ab_has_not_registered_ect)
        end

        it "returns the count of emails sent" do
          expect(service.contact_sits_that_need_to_chase_their_ab_to_register_ects).to eq 0
        end
      end

      context "when there are no eligible participants without a registered induction" do
        let!(:eligibility) { create(:seed_ecf_participant_eligibility, :no_induction, :no_qts, participant_profile:) }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_chase_their_ab_to_register_ects
          }.not_to have_enqueued_mail(SchoolMailer, :remind_sit_that_ab_has_not_registered_ect)
        end

        it "returns the count of emails sent" do
          expect(service.contact_sits_that_need_to_chase_their_ab_to_register_ects).to eq 0
        end
      end
    end
  end

  describe "#contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects" do
    let(:participant_profile) { create(:seed_ect_participant_profile, :valid, school_cohort:) }
    let(:ect_name) { participant_profile.user.full_name }

    let(:ect_appropriate_body) { nil }
    let(:school_appropriate_body) { nil }
    let!(:eligibility) { create(:seed_ecf_participant_eligibility, :no_induction, participant_profile:) }
    let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:, induction_programme:, appropriate_body: ect_appropriate_body) }

    before do
      school_cohort.update!(appropriate_body: school_appropriate_body)
    end

    context "when a school has ECTs without an AB and induction start date" do
      it "mails the induction coordinator" do
        expect {
          service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects
        }.to have_enqueued_mail(SchoolMailer, :remind_sit_to_appoint_ab_for_unregistered_ect)
          .with(params: { school:, induction_coordinator: sit_profile, ect_name:, lead_provider_name: lead_provider.name, delivery_partner_name: delivery_partner.name }, args: [])
      end

      it "returns the count of emails sent" do
        expect(service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects).to eq 1
      end

      context "when the AB is set at the school level" do
        let(:school_appropriate_body) { create(:seed_appropriate_body, :valid) }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects
          }.not_to have_enqueued_mail(SchoolMailer, :remind_sit_to_appoint_ab_for_unregistered_ect)
        end

        it "returns the count of emails sent" do
          expect(service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects).to eq 0
        end
      end

      context "when the AB is set at the participant level" do
        let(:school_appropriate_body) { create(:seed_appropriate_body, :valid) }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects
          }.not_to have_enqueued_mail(SchoolMailer, :remind_sit_to_appoint_ab_for_unregistered_ect)
        end

        it "returns the count of emails sent" do
          expect(service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects).to eq 0
        end
      end

      context "when the dry_run flag is set" do
        let(:dry_run) { true }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects
          }.not_to have_enqueued_mail(SchoolMailer, :remind_sit_to_appoint_ab_for_unregistered_ect)
        end

        it "returns the count of emails that would have been sent" do
          expect(service.contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects).to eq 1
        end
      end

      context "when there are no eligible participants without a registered induction" do
        let!(:eligibility) { create(:seed_ecf_participant_eligibility, :no_induction, :no_qts, participant_profile:) }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_chase_their_ab_to_register_ects
          }.not_to have_enqueued_mail(SchoolMailer, :remind_sit_that_ab_has_not_registered_ect)
        end

        it "returns the count of emails sent" do
          expect(service.contact_sits_that_need_to_chase_their_ab_to_register_ects).to eq 0
        end
      end
    end
  end

  describe "#contact_sits_that_need_to_assign_mentors" do
    let(:participant_profile) { create(:seed_ect_participant_profile, :valid, school_cohort:) }
    let!(:eligibility) { create(:seed_ecf_participant_eligibility, participant_profile:) }
    let(:mentor_profile) { nil }

    let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:, induction_programme:, mentor_profile:) }

    context "when a school has not assigned a mentor to an ECT" do
      it "mails the induction coordinator" do
        expect {
          service.contact_sits_that_need_to_assign_mentors
        }.to have_enqueued_mail(SchoolMailer, :remind_sit_to_assign_mentors_to_ects_email)
          .with(params: { school:, induction_coordinator: sit_profile, email_schedule: }, args: [])
      end

      context "when the dry_run flag is set" do
        let(:dry_run) { true }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_need_to_assign_mentors
          }.not_to have_enqueued_mail
        end

        it "returns the count of emails that would be sent" do
          expect(service.contact_sits_that_need_to_assign_mentors).to eq 1
        end
      end
    end

    context "when a school has no ECTs without mentors" do
      let(:mentor_profile) { create(:seed_mentor_participant_profile, :valid, school_cohort:) }

      it "does not mail the induction coordinator" do
        expect {
          service.contact_sits_that_need_to_assign_mentors
        }.not_to have_enqueued_mail
      end
    end
  end

  describe "#contact_sits_that_have_not_added_participants" do
    context "when a school has not added participants to this programme" do
      it "mails the induction coordinator" do
        expect {
          service.contact_sits_that_have_not_added_participants
        }.to have_enqueued_mail(SchoolMailer, :remind_sit_to_add_ects_and_mentors_email)
          .with(params: { school:, induction_coordinator: sit_profile, email_schedule: }, args: [])
      end
    end

    context "when a school has added participants" do
      let!(:induction_record) { create(:seed_induction_record, :valid, induction_programme:) }

      it "does not mail the induction coordinator" do
        expect {
          service.contact_sits_that_have_not_added_participants
        }.not_to have_enqueued_mail
      end
    end

    context "when the dry_run flag is set" do
      let(:dry_run) { true }

      it "does not mail the induction coordinator" do
        expect {
          service.contact_sits_that_have_not_added_participants
        }.not_to have_enqueued_mail
      end

      it "returns the count of emails that would be sent" do
        expect(service.contact_sits_that_have_not_added_participants).to eq 1
      end
    end
  end

  describe "#contact_sits_that_have_not_engaged" do
    context "when the school has not made a programme choice" do
      context "and ran FIP last year" do
        let(:nomination_link) { "http://nomination.example.com" }
        let(:sit_user) { sit_profile.user }
        let!(:query_cohort) { create(:seed_cohort, start_year: cohort.start_year + 1) }

        before do
          allow(service).to receive(:nomination_url).with(email: sit_user.email, school:).and_return(nomination_link)
        end

        it "mails the induction coordinator" do
          expect {
            service.contact_sits_that_have_not_engaged
          }.to have_enqueued_mail(SchoolMailer, :launch_ask_sit_to_report_school_training_details)
            .with(params: { sit_user: sit_profile.user, nomination_link: }, args: [])
        end

        context "when the dry_run flag is set" do
          let(:dry_run) { true }

          it "does not mail the induction coordinator" do
            expect {
              service.contact_sits_that_have_not_engaged
            }.not_to have_enqueued_mail
          end

          it "returns the count of emails that would be sent" do
            expect(service.contact_sits_that_have_not_engaged).to eq 1
          end
        end
      end

      context "and did not run FIP last year" do
        let!(:school) { create(:seed_school, :valid) }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_have_not_engaged
          }.not_to have_enqueued_mail
        end
      end
    end
  end

  describe "#contact_sits_that_have_chosen_fip_but_not_partnered_at_year_start" do
    context "when the school has chosen fip but not partnered" do
      let(:previous_cohort) { create(:seed_cohort, start_year: cohort.start_year - 1) }

      context "and did not partner last year" do
        let!(:previous_school_cohort) { create(:seed_school_cohort, :cip, school:, cohort: previous_cohort) }

        it "mails the induction coordinator" do
          expect {
            service.contact_sits_that_have_chosen_fip_but_not_partnered_at_year_start
          }.to have_enqueued_mail(SchoolMailer, :sit_needs_to_chase_partnership)
            .with(params: { school: }, args: [])
        end

        context "when the dry_run flag is set" do
          let(:dry_run) { true }

          it "does not mail the induction coordinator" do
            expect {
              service.contact_sits_that_have_chosen_fip_but_not_partnered_at_year_start
            }.not_to have_enqueued_mail
          end

          it "returns the count of emails that would be sent" do
            expect(service.contact_sits_that_have_chosen_fip_but_not_partnered_at_year_start).to eq 1
          end
        end
      end

      context "and partnered last year" do
        let!(:previous_school_cohort) { create(:seed_school_cohort, :fip, school:, cohort: previous_cohort) }
        let!(:previous_partnership) { create(:seed_partnership, :valid, school:, cohort: previous_cohort) }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_have_chosen_fip_but_not_partnered_at_year_start
          }.not_to have_enqueued_mail
        end
      end
    end
  end

  describe "#contact_sits_that_have_chosen_fip_but_not_partnered" do
    context "when the school has chosen fip but not partnered" do
      it "mails the induction coordinator" do
        expect {
          service.contact_sits_that_have_chosen_fip_but_not_partnered
        }.to have_enqueued_mail(SchoolMailer, :sit_needs_to_chase_partnership)
          .with(params: { school:, email_schedule: }, args: [])
      end

      context "when the dry_run flag is set" do
        let(:dry_run) { true }

        it "does not mail the induction coordinator" do
          expect {
            service.contact_sits_that_have_chosen_fip_but_not_partnered
          }.not_to have_enqueued_mail
        end

        it "returns the count of emails that would be sent" do
          expect(service.contact_sits_that_have_chosen_fip_but_not_partnered).to eq 1
        end
      end
    end
  end

  describe "#contact_sits_pre_term_to_report_any_changes" do
    context "when a school rans FIP or CIP and has not opted out of updates" do
      let(:nomination_url) { "http://nomination.example.com" }

      before do
        allow(service).to receive(:nomination_url).with(email: sit_profile.user.email, school:).and_return(nomination_url)
      end

      it "mails the induction coordinator" do
        expect {
          service.contact_sits_pre_term_to_report_any_changes
        }.to have_enqueued_mail(SchoolMailer, :sit_pre_term_reminder_to_report_any_changes)
          .with(params: { induction_coordinator: sit_profile, nomination_url: }, args: [])
      end
    end

    context "when the dry_run flag is set" do
      let(:dry_run) { true }

      it "does not mail the induction coordinator" do
        expect {
          service.contact_sits_pre_term_to_report_any_changes
        }.not_to have_enqueued_mail
      end

      it "returns the count of emails that would be sent" do
        expect(service.contact_sits_pre_term_to_report_any_changes).to eq 1
      end
    end
  end
end

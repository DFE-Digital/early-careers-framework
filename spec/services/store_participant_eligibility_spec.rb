# frozen_string_literal: true

require "rails_helper"

RSpec.describe StoreParticipantEligibility do
  describe ".call" do
    subject(:service) { described_class }
    let(:school) { create(:school) }
    let(:school_cohort) { create(:school_cohort, :fip, school:) }
    let(:ect_teacher_profile) { create(:teacher_profile, school:, trn: nil) }
    let(:mentor_teacher_profile) { create(:teacher_profile, school:, trn: nil) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:, teacher_profile: ect_teacher_profile) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:, teacher_profile: mentor_teacher_profile) }
    let!(:induction_tutor) { create(:user, :induction_coordinator, schools: [school]) }

    let(:eligibility_options) do
      {
        previous_participation: false,
        previous_induction: false,
        qts: true,
        different_trn: false,
        active_flags: false,
      }
    end

    it "creates an eligibility record for the participant" do
      expect {
        service.call(participant_profile: ect_profile, eligibility_options:)
      }.to change { ECFParticipantEligibility.count }.by(1)

      expect(ect_profile.ecf_participant_eligibility).to be_present
    end

    it "sets the status and reason" do
      service.call(participant_profile: ect_profile, eligibility_options:)

      expect(ect_profile.ecf_participant_eligibility).to be_eligible_status
      expect(ect_profile.ecf_participant_eligibility).to be_none_reason
    end

    it "calls service for eligibility triggers" do
      allow(RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile).to receive(:call).with(participant_profile: ect_profile)

      service.call(participant_profile: ect_profile, eligibility_options:)

      expect(RecordDeclarations::Actions::MakeDeclarationsEligibleForParticipantProfile).to have_received(:call)
    end

    context "when an eligibility record exists" do
      let!(:manual_check_record) { create(:ecf_participant_eligibility, :manual_check, participant_profile: ect_profile) }

      it "updates the existing eligibility record" do
        service.call(participant_profile: ect_profile, eligibility_options:)

        expect(manual_check_record.reload).to be_eligible_status
        expect(manual_check_record).to be_none_reason
      end
    end

    context "when ineligible status is determined" do
      context "without eligibility_notifications feature enabled" do
        it "does not send email notifications" do
          eligibility_options[:previous_induction] = true
          expect {
            service.call(participant_profile: ect_profile, eligibility_options:)
          }.to_not have_enqueued_mail(IneligibleParticipantMailer, :ect_previous_induction_email)
        end
      end

      context "with eligibility_notifications feature enabled", with_feature_flags: { eligibility_notifications: "active" } do
        context "when participant is an ECT" do
          it "sends the ect_previous_induction_email when reason is previous_induction" do
            eligibility_options[:previous_induction] = true
            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :ect_previous_induction_email)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: ect_profile,
              )
          end

          it "sends a specific email when the reason is previous induction and the ect was previously eligible" do
            create(:ecf_participant_eligibility, :eligible, participant_profile: ect_profile)
            eligibility_options[:previous_induction] = true
            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :ect_previous_induction_email_previously_eligible)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: ect_profile,
              )
          end

          it "sends the ect_no_qts_email when reason is no_qts" do
            eligibility_options[:qts] = false
            eligibility_options[:status] = :ineligible
            eligibility_options[:reason] = :no_qts
            eligibility_options[:manually_validated] = true
            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :ect_no_qts_email)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: ect_profile,
              )
          end

          it "sends the ect_active_flags_email when reason is active_flags" do
            eligibility_options[:active_flags] = true
            eligibility_options[:status] = :ineligible
            eligibility_options[:reason] = :active_flags
            eligibility_options[:manually_validated] = true
            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :ect_active_flags_email)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: ect_profile,
              )
          end

          it "sends emails to the ect and sit when the reason is exempt_from_induction" do
            additional_induction_coordinator = create(:user, :induction_coordinator, schools: [school])
            eligibility_options[:exempt_from_induction] = true
            eligibility_options[:status] = :ineligible
            eligibility_options[:reason] = :exempt_from_induction

            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: ect_profile,
              ).and have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email)
                  .with(
                    induction_tutor_email: additional_induction_coordinator.email,
                    participant_profile: ect_profile,
                  ).and have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email_to_ect)
                      .with(
                        participant_profile: ect_profile,
                      ).once
          end

          it "sends specific emails to the ect and sit when the reason is exempt_from_induction and they have declarations" do
            additional_induction_coordinator = create(:user, :induction_coordinator, schools: [school])
            create(:ecf_participant_eligibility, :eligible, participant_profile: ect_profile)
            create(:ect_participant_declaration, user: ect_profile.user, participant_profile: ect_profile)
            eligibility_options[:exempt_from_induction] = true
            eligibility_options[:status] = :ineligible
            eligibility_options[:reason] = :exempt_from_induction

            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email_previously_eligible)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: ect_profile,
              ).and have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email_previously_eligible)
                  .with(
                    induction_tutor_email: additional_induction_coordinator.email,
                    participant_profile: ect_profile,
                  ).and have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email_to_ect_previously_eligible)
                      .with(
                        participant_profile: ect_profile,
                      ).once
          end

          it "doesn't send emails when the reason is exempt from induction, they were previously eligible but don't have declarations" do
            create(:ecf_participant_eligibility, :eligible, participant_profile: ect_profile)
            eligibility_options[:exempt_from_induction] = true
            eligibility_options[:status] = :ineligible
            eligibility_options[:reason] = :exempt_from_induction

            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.to not_have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email)
              .and not_have_enqueued_mail(IneligibleParticipantMailer, :ect_exempt_from_induction_email_to_ect)
          end
        end

        context "when participant is a Mentor" do
          it "does not send the mentor_previous_participation_email when reason is previous_participation" do
            eligibility_options[:previous_participation] = true
            expect {
              service.call(participant_profile: mentor_profile, eligibility_options:)
            }.to_not have_enqueued_mail(IneligibleParticipantMailer)
          end

          it "sends the mentor_no_qts_email when reason is no_qts" do
            eligibility_options[:qts] = false
            eligibility_options[:status] = :ineligible
            eligibility_options[:reason] = :no_qts
            eligibility_options[:manually_validated] = true
            expect {
              service.call(participant_profile: mentor_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :mentor_no_qts_email)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: mentor_profile,
              )
          end

          it "sends the mentor_active_flags_email when reason is active_flags" do
            eligibility_options[:active_flags] = true
            eligibility_options[:status] = :ineligible
            eligibility_options[:reason] = :active_flags
            eligibility_options[:manually_validated] = true
            expect {
              service.call(participant_profile: mentor_profile, eligibility_options:)
            }.to have_enqueued_mail(IneligibleParticipantMailer, :mentor_active_flags_email)
              .with(
                induction_tutor_email: induction_tutor.email,
                participant_profile: mentor_profile,
              )
          end
        end

        context "when the school is doing CIP" do
          let(:school_cohort) { create(:school_cohort, :cip, school:) }

          context "when participant is an ECT" do
            it "does not send the ect_previous_induction_email when reason is previous_induction" do
              eligibility_options[:previous_induction] = true

              expect {
                service.call(participant_profile: ect_profile, eligibility_options:)
              }.to_not have_enqueued_mail(IneligibleParticipantMailer)
            end

            it "does not send the ect_no_qts_email when reason is no_qts" do
              eligibility_options[:qts] = false
              eligibility_options[:status] = :ineligible
              eligibility_options[:reason] = :no_qts
              eligibility_options[:manually_validated] = true
              expect {
                service.call(participant_profile: ect_profile, eligibility_options:)
              }.to_not have_enqueued_mail(IneligibleParticipantMailer)
            end

            it "does not send the ect_active_flags_email when reason is active_flags" do
              eligibility_options[:active_flags] = true
              eligibility_options[:status] = :ineligible
              eligibility_options[:reason] = :active_flags
              eligibility_options[:manually_validated] = true
              expect {
                service.call(participant_profile: ect_profile, eligibility_options:)
              }.to_not have_enqueued_mail(IneligibleParticipantMailer)
            end
          end

          context "when participant is a Mentor" do
            it "does not send the mentor_previous_participation_email when reason is previous_participation" do
              eligibility_options[:previous_participation] = true
              expect {
                service.call(participant_profile: mentor_profile, eligibility_options:)
              }.to_not have_enqueued_mail(IneligibleParticipantMailer)
            end

            it "does not send the mentor_no_qts_email when reason is no_qts" do
              eligibility_options[:qts] = false
              eligibility_options[:status] = :ineligible
              eligibility_options[:reason] = :no_qts
              eligibility_options[:manually_validated] = true
              expect {
                service.call(participant_profile: mentor_profile, eligibility_options:)
              }.to_not have_enqueued_mail(IneligibleParticipantMailer)
            end

            it "sends the mentor_active_flags_email when reason is active_flags" do
              eligibility_options[:active_flags] = true
              eligibility_options[:status] = :ineligible
              eligibility_options[:reason] = :active_flags
              eligibility_options[:manually_validated] = true
              expect {
                service.call(participant_profile: mentor_profile, eligibility_options:)
              }.to_not have_enqueued_mail(IneligibleParticipantMailer)
            end
          end
        end
      end
    end

    context "when eligible status is determined" do
      context "when no record existed previously" do
        it "does not send an email" do
          expect {
            service.call(participant_profile: ect_profile, eligibility_options:)
          }.not_to have_enqueued_mail
        end
      end

      context "when the status was manual check before" do
        let!(:manual_check_record) { create(:ecf_participant_eligibility, :manual_check, participant_profile: ect_profile) }

        it "does not send an email" do
          expect {
            service.call(participant_profile: ect_profile, eligibility_options:)
          }.not_to have_enqueued_mail
        end
      end

      context "when the status was ineligible and the reason was not previous induction" do
        let!(:ineligible_record) { create(:ecf_participant_eligibility, :ineligible, reason: "no_qts", participant_profile: ect_profile) }

        it "does not send an email" do
          expect {
            service.call(participant_profile: ect_profile, eligibility_options:)
          }.not_to have_enqueued_mail
        end
      end

      context "when the status was ineligible and the reason was previous induction" do
        let!(:ineligible_record) { create(:ecf_participant_eligibility, :ineligible, reason: "previous_induction", participant_profile: ect_profile) }

        it "sends an ect now eligible email" do
          expect {
            service.call(participant_profile: ect_profile, eligibility_options:)
          }.to have_enqueued_mail(IneligibleParticipantMailer)
        end

        context "when the school is doing CIP" do
          let(:school_cohort) { create(:school_cohort, :cip, school:) }

          it "does not send an email" do
            expect {
              service.call(participant_profile: ect_profile, eligibility_options:)
            }.not_to have_enqueued_mail
          end
        end
      end
    end
  end
end

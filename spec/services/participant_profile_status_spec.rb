# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfileStatus, :with_default_schedules do
  let(:participant_profile) { create(:ecf_participant_profile) }
  let!(:induction_record) { create(:induction_record, participant_profile:) }

  let(:params) { { participant_profile:, induction_record: } }

  subject { described_class.new(**params) }

  describe "#initialize" do
    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@participant_profile)).to eq(participant_profile)
    end

    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@induction_record)).to eq(induction_record)
    end
  end

  describe "#status_name" do
    context "when the request for details has not been sent yet" do
      it "returns the correct status" do
        response = subject.status_name
        expect(response).to eq("contacted_for_information")
      end
    end

    context "with a request for details email record" do
      let!(:email) { create(:email, tags: %i[request_for_details], associated_with: participant_profile, status: email_status) }

      context "which has been successfully delivered" do
        let(:email_status) { :delivered }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("contacted_for_information")
        end
      end

      context "which has failed to be deliver" do
        let(:email_status) { Email::FAILED_STATUSES.sample }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("contacted_for_information")
        end
      end

      context "which is still pending" do
        let(:email_status) { :submitted }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("contacted_for_information")
        end
      end
    end

    context "mentor with multiple profiles" do
      let(:school_cohort) { create(:school_cohort) }

      context "when the primary profile is eligible" do
        let(:participant_profile) { create(:mentor_participant_profile, :primary_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("training_or_eligible_for_training")
        end
      end

      context "when the secondary profile is ineligible because it is a duplicate" do
        let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("training_or_eligible_for_training")
        end
      end
    end

    context "full induction programme participant" do
      context "has submitted validation data" do
        let(:school_cohort) { create(:school_cohort, :fip) }
        let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("training_or_eligible_for_training")
        end
      end

      context "was a participant in early roll out" do
        let(:school_cohort) { create(:school_cohort, :fip) }
        let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("training_or_eligible_for_training")
        end
      end
    end

    context "core induction programme participant" do
      context "has submitted validation data" do
        let(:school_cohort) { create(:school_cohort, :cip) }
        let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :manual_check, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("dfe_checking_eligibility")
        end
      end

      context "has a previous induction reason" do
        let(:school_cohort) { create(:school_cohort, :cip) }
        let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("not_eligible_for_funded_training")
        end
      end

      context "has no QTS reason" do
        let(:school_cohort) { create(:school_cohort, :cip) }
        let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("checking_qts")
        end
      end

      context "has an ineligible status" do
        let(:school_cohort) { create(:school_cohort, :cip) }
        let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :ineligible, participant_profile:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("not_eligible_for_funded_training")
        end
      end

      context "has a withdrawn status" do
        let(:school_cohort) { create(:school_cohort, :fip) }
        let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:) }
        let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }
        let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
        let!(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }

        it "returns the correct status" do
          response = subject.status_name
          expect(response).to eq("training_or_eligible_for_training")
        end

        context "when induction record does not exist" do
          let(:participant_profile) { create(:ecf_participant_profile, training_status: "withdrawn") }
          let!(:induction_record) { nil }

          it "returns the correct status" do
            response = subject.status_name
            expect(response).to eq("no_longer_being_trained")
          end
        end
      end
    end
  end
end

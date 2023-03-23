# frozen_string_literal: true

RSpec.describe ParticipantStatusTagStatus, :with_default_schedules do
  let!(:participant_profile) { create :ect_participant_profile }

  subject { described_class.new(participant_profile:).record_state }

  context "when the request for details has not been sent yet" do
    it { is_expected.to eq :checks_not_complete } # "Contacting for information"
  end

  context "with a request for details email record" do
    let!(:email) { create :email, tags: %i[request_for_details], associated_with: participant_profile, status: email_status }

    context "which has been successfully delivered" do
      let(:email_status) { :delivered }

      it { is_expected.to eq :request_for_details_delivered } # "Contacted for information"
    end

    context "which has failed to be deliver" do
      let(:email_status) { Email::FAILED_STATUSES.sample }

      it { is_expected.to eq :request_for_details_failed } # "Check email address"
    end

    context "which is still pending" do
      let(:email_status) { :submitted }

      it { is_expected.to eq :checks_not_complete } # "Contacting for information"
    end
  end

  context "mentor with multiple profiles" do
    let(:school_cohort) { create(:school_cohort) }

    context "when the primary profile is eligible" do
      let(:participant_profile) { create(:mentor_participant_profile, :primary_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      before do
        participant_profile.reload
      end

      it { is_expected.to eq :registered_for_mentor_training } # "Eligible: Mentor at main school" }
    end

    context "when the secondary profile is ineligible because it is a duplicate" do
      let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile:) }

      before do
        participant_profile.reload
      end

      it { is_expected.to eq :registered_for_mentor_training_second_school } # "Eligible: Mentor at additional school"
    end
  end

  context "full induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      it { is_expected.to eq :registered_for_fip_training } # "Eligible to start"
    end

    context "was a participant in early roll out" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

      it { is_expected.to eq :previous_participation_ero } # "Eligible to start: ERO"
    end
  end

  context "core induction programme participant" do
    context "has submitted validation data" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

      it { is_expected.to eq :manual_check } # "DfE checking eligibility"
    end

    context "has a previous induction reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

      it { is_expected.to eq :previous_induction } # "Not eligible: NQT+1" - TODO: will this always be NQT+1 ?
    end

    context "has no QTS reason" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

      it { is_expected.to eq :not_qualified } # "Not eligible: No QTS"
    end

    context "has an ineligible status" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

      it { is_expected.to eq :previous_induction } # "Not eligible"
    end

    context "has a withdrawn status" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:participant_profile) { create(:ect_participant_profile, training_status: "withdrawn", school_cohort:) }
      let!(:ecf_participant_eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

      context "when there is not induction record to use" do
        it { is_expected.to eq :withdrawn_training } # "Withdrawn by provider"
      end

      context "when an active induction record is available" do
        let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
        let(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }

        subject { described_class.new(participant_profile:, induction_record:).record_state }

        it { is_expected.to eq :registered_for_fip_training } # "Eligible to start" }
      end
    end
  end
end
